import os
import requests
from flask import Flask, request, jsonify
import redis # docker-compose

from app.models import TaskManager


app = Flask(__name__)
manager = TaskManager()


# docker-compose
redis_client = redis.Redis(
    host=os.environ.get("REDIS_HOST", "localhost"),
    port=int(os.environ.get("REDIS_PORT", 6379)),
    decode_responses=True,
)

@app.get("/hits")
def hits():
    n = redis_client.incr("hits")
    return {"hits": n}


@app.get("/")
def root():
    return {"service": "todo-app", "endpoints": ["/tasks"]}


@app.get("/tasks")
def list_tasks():
    return jsonify(manager.list_all())


@app.post("/tasks")
def create_task():
    data = request.get_json(force=True)
    title = data.get("title")
    if not title:
        return {"error": "title is required"}, 400
    task = manager.add(title)
    return task.to_dict(), 201


@app.post("/tasks/<int:task_id>/done")
def finish_task(task_id: int):
    task = manager.mark_done(task_id)
    if task is None:
        return {"error": "not found"}, 404
    return task.to_dict()


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5009))
    app.run(host="0.0.0.0", port=port)