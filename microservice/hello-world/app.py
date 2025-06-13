from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello World from GitHub CI/CD 🛠️🚀, estaes una prueba de flujo para mosrtar en entrevista'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5678)
