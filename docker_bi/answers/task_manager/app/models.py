from datetime import datetime


class Task:
    def __init__(self, task_id: int, title: str):
        self.id = task_id
        self.title = title
        self.done = False
        self.created_at = datetime.now()

    def mark_done(self) -> None:
        self.done = True

    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "title": self.title,
            "done": self.done,
            "created_at": self.created_at.isoformat(),
        }


class TaskManager:
    def __init__(self):
        self._tasks: dict[int, Task] = {}
        self._next_id = 1

    def add(self, title: str) -> Task:
        task = Task(self._next_id, title)
        self._tasks[self._next_id] = task
        self._next_id += 1
        return task

    def list_all(self) -> list[dict]:
        return [t.to_dict() for t in self._tasks.values()]

    def mark_done(self, task_id: int) -> Task | None:
        task = self._tasks.get(task_id)
        if task is None:
            return None
        task.mark_done()
        return task