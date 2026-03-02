# Smart-Contract-Hotel-Booking-System

A blockchain-based hotel booking system built using Solidity smart contracts to enable secure, transparent, and decentralized room reservations.

## Hotel Booking DApp (Remix + Flask + Web3.py)

A simple decentralized hotel booking project where a Flask backend sends booking transactions to a Solidity smart contract deployed from Remix.

## Tech Stack
- Solidity (contract authored/deployed via Remix IDE)
- Ganache (local Ethereum blockchain)
- Flask (Python backend + basic UI)
- Web3.py (smart contract interaction)

## Project Structure
- `HotelBooking.sol`: Solidity smart contract
- `HotelbookingABI.json`: Contract ABI used by the backend
- `app.py`: Flask server and Web3 integration
- `test_booking.py`: API test client script
- `templates/index.html`: Simple browser UI

## Prerequisites
- Python 3.10+
- Ganache running on `http://127.0.0.1:7545`
- A deployed `HotelBooking` contract address in `app.py`
- Private key of a funded Ganache account in `.env`

## Environment
Create `.env`:

```env
PRIVATE_KEY=0xYOUR_64_HEX_PRIVATE_KEY
```

## Install Dependencies
```powershell
python -m pip install flask web3 python-dotenv requests
```

## Run the App
```powershell
python app.py
```

Open in browser:
- `http://127.0.0.1:5050`

## Test API via Script
In a second terminal (while app is running):

```powershell
python test_booking.py
```

Expected success response:
- HTTP 200
- JSON containing `txHash`

## API Endpoint
- `POST /book`

Request body example:

```json
{
  "checkIn": 1710000000,
  "checkOut": 1710086400
}
```

## Notes
- If you restart/switch Ganache workspace, redeploy the contract and update `contract_address` in `app.py`.
- Do not commit `.env` or private keys to GitHub.
