import {
  getArgs,
  formattedTodos,
  addTodo,
  markDone,
  clearTodos
} from './todo.mjs'
import assert from 'node:assert'
import { describe, it, afterEach } from 'node:test'
import * as fs from 'node:fs/promises'

const FILE_PATH = './tests_tasks.todo'

describe('todo', () => {
  const defaultArgv = process.argv

  afterEach(() => {
    process.argv = defaultArgv
    fs.unlink(FILE_PATH)
  })

  it('getArgs', () => {
    process.argv = [...process.argv, 'add', 'one', 'two']

    assert.deepEqual(getArgs(), {
      command: 'add',
      args: ['one', 'two']
    })
  })

  it('formattedTodos', async () => {
    await fs.writeFile(
      FILE_PATH,
      `[ ] first todo
[*] second todo
`
    )
    const todos = await formattedTodos(FILE_PATH)

    assert.equal(
      todos,
      `1 first todo
2 \x1b[9msecond todo\x1b[29m`
    )
  })

  it('addTodo', async () => {
    await addTodo(FILE_PATH, 'first todo')
    await addTodo(FILE_PATH, 'second todo')
    const content = await fs.readFile(FILE_PATH, 'utf8')
    assert.equal(
      content,
      `[ ] first todo
[ ] second todo
`
    )
  })

  it('done', async () => {
    await fs.writeFile(
      FILE_PATH,
      `[ ] first todo
[ ] second todo
[ ] third todo
[ ] fourth todo
`
    )
    await markDone(FILE_PATH, [2, 4])
    const content = await fs.readFile(FILE_PATH, 'utf8')
    assert.equal(
      content,
      `[ ] first todo
[*] second todo
[ ] third todo
[*] fourth todo
`
    )
  })

  it('clear', async () => {
    await fs.writeFile(
      FILE_PATH,
      `[ ] first todo
[ ] second todo
`
    )
    await clearTodos(FILE_PATH)
    const content = await fs.readFile(FILE_PATH, 'utf8')
    assert.equal(content, '')
  })
})
