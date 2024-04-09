import gleeunit
import gleeunit/should
import simplifile
import gleam_todos.{formatted_todos, add_todo, clear_todos, mark_done}
import gleam_community/ansi

const file_path = "test.todo"

pub fn main() {
  gleeunit.main()
}

pub fn formatted_todos_test() {
  let todos =
  "[ ] first todo
[*] second todo
"
  let assert Ok(_) = simplifile.write(file_path, todos)
  let assert Ok(todos) = formatted_todos(file_path)
  todos
  |> should.equal("1 first todo
2 " <> ansi.strikethrough("second todo") <> "
")

  simplifile.delete(file_path)
}

pub fn add_todo_test() {
  let _ = simplifile.delete(file_path)
  let assert Ok(_) = add_todo(file_path, "first todo")
  let assert Ok(_) = add_todo(file_path, "second todo")

  let assert Ok(content) = simplifile.read(file_path)
  content
  |> should.equal("[ ] first todo
[ ] second todo
")

  simplifile.delete(file_path)
}

pub fn clear_todos_test() {
  let todos =
  "[ ] first todo
[*] second todo
"
  let assert Ok(_) = simplifile.write(file_path, todos)
  let assert Ok(_) = clear_todos(file_path)

  let assert Ok(content) = simplifile.read(file_path)
  content
  |> should.equal("")

  simplifile.delete(file_path)
}

pub fn mark_done_test() {
  let todos =
  "[ ] first todo
[ ] second todo
[ ] third todo
[ ] fourth todo
"
  let assert Ok(_) = simplifile.write(file_path, todos)

  let assert Ok(_) = mark_done(file_path, [2, 4])

  let assert Ok(content) = simplifile.read(file_path)
  content
  |> should.equal("[ ] first todo
[*] second todo
[ ] third todo
[*] fourth todo
")

  simplifile.delete(file_path)
}