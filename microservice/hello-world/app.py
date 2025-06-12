from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello World from GitHub CI/CD 🛠️🚀, esta es otra prueba casi terminando a las 4 am, prueba de eliminacion rollout'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5678)
