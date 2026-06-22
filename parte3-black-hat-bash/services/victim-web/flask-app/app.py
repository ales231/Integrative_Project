from flask import Flask, render_template_string

app = Flask(__name__)

UPLOAD_FORM = """
<!DOCTYPE html>
<html>
<head><title>Upload</title></head>
<body>
  <h1>File Upload</h1>
  <form method="post" enctype="multipart/form-data">
    <input type="file" name="file">
    <button type="submit">Upload</button>
  </form>
</body>
</html>
"""

UPLOADS_LIST = "<html><body><h1>Uploads</h1><p>uploads/</p></body></html>"


@app.route("/")
def index():
    return "ACME Hyper Branding — internal app", 200


@app.route("/upload", methods=["GET", "POST"])
def upload():
    return render_template_string(UPLOAD_FORM), 200


@app.route("/uploads", methods=["GET"])
def uploads():
    return UPLOADS_LIST, 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8081)
