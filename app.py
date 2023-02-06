from flask import Flask, request, render_template, redirect, url_for, g
import digitalocean
import os
import ssl
from flask_login import LoginManager, current_user, UserMixin, login_user, logout_user, login_required

app = Flask(__name__, template_folder='templates')
login_manager = LoginManager(app)
app.secret_key = os.urandom(24)


def spin_up_server(num_servers, instance_type):
    # Initialize the DigitalOcean API client
    manager = digitalocean.Manager(token=os.environ.get("DO_TOKEN"))

    # Create the instances
    instances = []
    for i in range(num_servers):
        instance = digitalocean.Droplet(
            token=os.environ.get("DO_TOKEN"),
            name="server" + str(i + 1),
            region="nyc3",  # Replace with desired region
            image="ubuntu-20-04-x64",  # Replace with desired image
            size_slug=instance_type,
            ssh_keys=manager.get_all_sshkeys(),
        )
        instance.create()
        instances.append(instance)

    # Wait for the instances to be active
    for instance in instances:
        instance.load()
        while instance.status != "active":
            instance.load()

    # Return the list of instances
    return instances


class User(UserMixin):
    def __init__(self, id, name, password):
        self.id = id
        self.name = name
        self.password = password

    def __repr__(self):
        return f"User(id={self.id}, name={self.name})"


# Example users
users = [User(1, "user1", "password1"), User(2, "user2", "password2")]

# Create a dictionary mapping usernames to User objects
user_by_name = {user.name: user for user in users}


# Load a user from its ID
@login_manager.user_loader
def load_user(user_id):
    for user in users:
        if str(user.id) == str(user_id):
            return user
    return None


@app.before_request
def before_request():
    g.current_user = current_user


@app.route("/", methods=["GET"])
def index():
    if "username" in request.cookies:
        return redirect(url_for("spin_up_server_route"))
    return render_template("index.html", current_user=g.current_user)


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "GET":
        return render_template("login.html")

    if request.method == "POST":
        name = request.form.get("username")
        password = request.form.get("password")

        user = user_by_name.get(name)

        if user and user.password == password:
            login_user(user)
            return redirect(url_for("spin_up_server_route"))
        else:
            return "Incorrect username or password"


# Logout route
@app.route("/logout")
@login_required
def logout():
    logout_user()
    return redirect(url_for("index"))


@app.route("/spin_up_server", methods=["GET", "POST"])
def spin_up_server_route():
    if request.method == "POST":
        num_servers = int(request.form["num_servers"])
        instance_type = request.form["instance_type"]
        servers = spin_up_server(num_servers, instance_type)
        return render_template("servers.html", servers=servers)
    return render_template("spin_up_server.html")


if __name__ == "__main__":
    app.run(debug=True)
