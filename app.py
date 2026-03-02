from flask import Flask, request, jsonify, render_template
from web3 import Web3
from dotenv import load_dotenv
import json, os
import re

load_dotenv(override=True)
app = Flask(__name__)
web3 = Web3(Web3.HTTPProvider("http://127.0.0.1:7545"))

# Load ABI
with open("HotelbookingABI.json") as f:
    abi = json.load(f)

# Contract setup
contract_address = "0xd9145CCE52D386f254917e481eB44e9943F39138"
contract = web3.eth.contract(address=contract_address, abi=abi)

@app.route('/book', methods=['POST'])
def book_room():
    data = request.get_json(silent=True) or {}

    # Step 3: Validate input presence
    if 'checkIn' not in data or 'checkOut' not in data:
        return jsonify({'error': 'Missing checkIn or checkOut'}), 400

    check_in = int(data.get('checkIn', 0))
    check_out = int(data.get('checkOut', 0))

    # Step 3: Validate logical timestamp order
    if check_out <= check_in:
        return jsonify({'error': 'checkOut must be after checkIn'}), 400

    sender = web3.eth.accounts[0]

    # Step 4: Load and validate private key
    private_key = os.getenv("PRIVATE_KEY", "").strip().strip('"').strip("'")
    if not private_key:
        return jsonify({'error': 'Private key not found in environment'}), 500
    if private_key.startswith("0x"):
        private_key = private_key[2:]
    if not re.fullmatch(r"[0-9a-fA-F]{64}", private_key):
        return jsonify({'error': 'Invalid private key format. Expect 64 hex chars.'}), 500
    private_key = "0x" + private_key

    # Build transaction
    tx = contract.functions.bookRoom(check_in, check_out).build_transaction({
        'from': sender,
        'value': web3.to_wei(1, 'ether'),
        'gas': 3000000,
        'nonce': web3.eth.get_transaction_count(sender)
    })

    # Step 5: Wrap signing and sending in try-except
    try:
        signed_tx = web3.eth.account.sign_transaction(tx, private_key=private_key)
        tx_hash = web3.eth.send_raw_transaction(signed_tx.raw_transaction)
        return jsonify({'txHash': tx_hash.hex()})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/', methods=['GET'])
def home():
    return render_template('index.html')

if __name__ == '__main__':
    app.run(debug=True, port=5050)
