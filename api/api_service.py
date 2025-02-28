from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/', methods=['GET'])
def func():
    return jsonify({'message': 'Hello, World! from the api container'})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)