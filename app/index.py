from flask import Flask, render_template, Blueprint
from .auth import bp
# adjust the import path according to your project structure
from .db import init_app, get_db
import os

app = Flask(__name__)
app.config['DATABASE'] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), 'data.db')
init_app(app)
print(app.config['DATABASE'])


@app.route('/show-db-path')
def show_db_path():
    db_path = app.config['DATABASE']
    abs_db_path = os.path.abspath(db_path)
    return f"The database path is: {abs_db_path}"


app.register_blueprint(bp, url_prefix='/auth')
main = Blueprint('main', __name__)


@app.route("/")
def index():
    db = get_db()
    print(app.config["DATABASE"])
    # user = db.execute("SELECT username" " From user").fetchone()

    # if user:
    #     return render_template("index.html", user=user["username"])
    # else:
    return render_template("index.html")


# Register the main Blueprint
app.register_blueprint(main)

if __name__ == '__main__':
    app.run(debug=True)
