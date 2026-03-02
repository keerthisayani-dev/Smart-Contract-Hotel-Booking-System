// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HotelBooking {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    struct Booking {
        uint256 id;
        address guest;
        uint256 checkIn;
        uint256 checkOut;
        uint256 amountPaid;
        bool isCancelled;
        uint256 refundAmount;
    }

    mapping(uint256 => Booking) public bookings;
    uint256 public bookingCounter = 0;

    event RoomBooked(uint256 id, address guest, uint256 checkIn, uint256 checkOut, uint256 amountPaid);
    event BookingCancelled(uint256 id, address guest, uint256 refundAmount);

    function bookRoom(uint256 _checkIn, uint256 _checkOut) external payable {
        require(msg.value > 0, "Payment required");
        require(_checkOut > _checkIn, "Invalid check-out time");

        bookings[bookingCounter] = Booking({
            id: bookingCounter,
            guest: msg.sender,
            checkIn: _checkIn,
            checkOut: _checkOut,
            amountPaid: msg.value,
            isCancelled: false,
            refundAmount: 0
        });

        emit RoomBooked(bookingCounter, msg.sender, _checkIn, _checkOut, msg.value);
        bookingCounter++;
    }

    function cancelBooking(uint256 _bookingId) external {
        Booking storage booking = bookings[_bookingId];
        require(msg.sender == booking.guest, "Not your booking");
        require(!booking.isCancelled, "Already cancelled");

        booking.isCancelled = true;

        if (block.timestamp < booking.checkIn) {
            uint256 refund = booking.amountPaid;
            booking.refundAmount = refund;
            booking.amountPaid = 0;
            payable(booking.guest).transfer(refund);
        }

        emit BookingCancelled(_bookingId, booking.guest, booking.refundAmount);
    }

    function getBooking(uint256 _id) external view returns (
        address guest,
        uint256 checkIn,
        uint256 checkOut,
        uint256 amountPaid,
        bool isCancelled,
        uint256 refundAmount
    ) {
        Booking memory b = bookings[_id];
        return (b.guest, b.checkIn, b.checkOut, b.amountPaid, b.isCancelled, b.refundAmount);
    }
}