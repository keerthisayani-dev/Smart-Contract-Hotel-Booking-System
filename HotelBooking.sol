// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title HotelCancellation Smart Contract (Improved + Safe Version)
 * @dev Automates hotel booking, cancellation, and refund with clearer conditions and safety checks
 */
contract HotelCancellation {
    address payable public hotelOwner;
    address payable public guest;
    uint256 public bookingAmount;
    uint256 public checkInTime;
    bool public isCancelled;
    bool public isCheckedIn;

    enum BookingState {
        Booked,
        Cancelled,
        CheckedIn,
        Completed
    }

    BookingState public currentState;

    event Booked(address indexed guest, uint256 amount, uint256 checkInTime);
    event Cancelled(address indexed guest, uint256 refundAmount);
    event CheckedIn(address indexed hotelOwner);
    event Completed(address indexed hotelOwner);

    // Simple reentrancy guard
    bool private locked;
    modifier nonReentrant() {
        require(!locked, "Reentrancy blocked");
        locked = true;
        _;
        locked = false;
    }

    constructor(address payable _hotelOwner, uint256 _checkInTime) payable {
        require(_hotelOwner != address(0), "Invalid hotel owner");
        require(msg.value > 0, "Booking amount required");
        require(_checkInTime > block.timestamp, "Invalid check-in time");

        hotelOwner = _hotelOwner;
        guest = payable(msg.sender);
        bookingAmount = msg.value;
        checkInTime = _checkInTime;

        currentState = BookingState.Booked;

        emit Booked(guest, msg.value, _checkInTime);
    }

    /// @notice Guest can cancel before check-in
    function cancelBooking() external nonReentrant {
        require(msg.sender == guest, "Only guest can cancel");
        require(currentState == BookingState.Booked, "Booking already finalized");

        isCancelled = true;
        currentState = BookingState.Cancelled;

        uint256 refundAmount;
        uint256 timeBeforeCheckIn = checkInTime - block.timestamp; // safe due to state check & require in constructor

        if (timeBeforeCheckIn >= 48 hours) {
            refundAmount = bookingAmount; // Full refund
        } else if (timeBeforeCheckIn >= 24 hours) {
            refundAmount = bookingAmount / 2; // 50% refund
        } else {
            refundAmount = 0; // No refund
        }

        // Pay refund to guest (if any)
        if (refundAmount > 0) {
            (bool okRefund, ) = guest.call{value: refundAmount}("");
            require(okRefund, "Refund transfer failed");
        }

        // Send remaining to hotel owner
        uint256 remaining = address(this).balance;
        if (remaining > 0) {
            (bool okOwner, ) = hotelOwner.call{value: remaining}("");
            require(okOwner, "Owner transfer failed");
        }

        emit Cancelled(guest, refundAmount);
    }

    /// @notice Hotel confirms guest check-in
    function confirmCheckIn() external nonReentrant {
        require(msg.sender == hotelOwner, "Only hotel can confirm check-in");
        require(currentState == BookingState.Booked, "Booking is not valid for check-in");
        require(block.timestamp >= checkInTime, "Too early to check-in");

        isCheckedIn = true;
        currentState = BookingState.CheckedIn;

        // Hotel receives the full balance on check-in
        uint256 bal = address(this).balance;
        if (bal > 0) {
            (bool ok, ) = hotelOwner.call{value: bal}("");
            require(ok, "Payout failed");
        }

        emit CheckedIn(hotelOwner);
    }

    /// @notice Hotel marks stay as completed
    function completeStay() external {
        require(msg.sender == hotelOwner, "Only hotel can complete stay");
        require(currentState == BookingState.CheckedIn, "Guest not checked-in");

        currentState = BookingState.Completed;
        emit Completed(hotelOwner);
    }

    /// @notice Returns contract balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /// @notice Returns a human-readable booking state
    function getBookingState() external view returns (string memory) {
        if (currentState == BookingState.Booked) return "Booked";
        if (currentState == BookingState.Cancelled) return "Cancelled";
        if (currentState == BookingState.CheckedIn) return "Checked-In";
        if (currentState == BookingState.Completed) return "Completed";
        return "Unknown";
    }
}