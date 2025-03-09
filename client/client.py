from flask import Flask, jsonify
import requests  # Use the correct requests module

app = Flask(__name__)

@app.route('/', methods=['GET'])
def func():
    response = requests.get('http://api:5000/') # there will be localhost instead of contianer name in ECS fargate awsvpc
    return jsonify({'message': 'The API container responded with: ' + response.json()['message']})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)  # Run on port 8000
