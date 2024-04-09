import gleam/io
import argv
import simplifile
import gleam/string
import gleam/list
import gleam/int
import gleam/result
import gleam_community/ansi

const file_path = "my.todo"

pub fn main() {
  case argv.load().arguments {
    ["add", title] -> add_todo(file_path, title)
    ["list"] | [] -> {
      case formatted_todos(file_path) {
        Ok(todos) -> Ok(io.println(todos))
        _ -> Ok(Nil)
      }
    }
    ["clear"] -> clear_todos(file_path)
    ["done", ..ids] -> mark_done(file_path, list.map(ids, fn(id) { result.unwrap(int.parse(id), 0) }))
    _ -> Ok(Nil)
  }
}

pub fn formatted_todos(file_path: String) -> Result(String, Nil) {
  simplifile.read(file_path)
  |> result.map(split_to_lines)
  |> result.map(format_todo_lines)
  |> result.map(join_lines)
  |> result.nil_error
}

pub fn add_todo(file_path: String, title: String) -> Result(Nil, Nil) {
  simplifile.append(file_path, "[ ] " <> title <> "\n")
  |> result.replace(Nil)
  |> result.nil_error
}

pub fn clear_todos(file_path: String) -> Result(Nil, Nil) {
  simplifile.write(file_path, "")
  |> result.replace(Nil)
  |> result.nil_error
}

pub fn mark_done(file_path: String, ids: List(Int)) -> Result(Nil, Nil) {
  simplifile.read(file_path)
  |> result.map(split_to_lines)
  |> result.map(fn(lines) { mark_todo_done(lines, ids) })
  |> result.map(join_lines)
  |> result.try(fn(content) { simplifile.write(file_path, content) })
  |> result.nil_error
}

fn split_to_lines(content: String) -> List(String) {
  string.split(content, "\n")
}

fn join_lines(lines: List(String)) -> String {
  string.join(lines, "\n")
}

fn format_todo_lines(lines: List(String)) -> List(String) {
  list.index_map(lines, fn(line, index) {
    case line {
      "[ ] " <> rest -> int.to_string(index + 1) <> " " <> rest
      "[*] " <> rest -> int.to_string(index + 1) <> " " <> ansi.strikethrough(rest)
      _ -> line
    }
  })
}

fn mark_todo_done(lines: List(String), ids: List(Int)) -> List(String){
  list.index_map(lines, fn(line, index) {
    case line {
      "[ ]" <> rest -> {
        case list.contains(ids, index + 1) {
          True -> "[*]" <> rest
          False -> line
        }
      }
      _ -> line
    }
  })
}