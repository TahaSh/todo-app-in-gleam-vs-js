import * as fs from 'node:fs/promises'

const FILE_PATH = './my.todo'

async function main() {
  const { command, args } = getArgs()
  switch (command) {
    case 'add':
      await addTodo(FILE_PATH, args[0])
      break
    case 'list':
      console.log(await formattedTodos(FILE_PATH))
      break
    case 'clear':
      await clearTodos(FILE_PATH)
      break
    case 'done':
      await markDone(FILE_PATH, args)
      break
  }
}

export function getArgs() {
  const [, , command, ...args] = process.argv
  return {
    command,
    args
  }
}

async function useTodoFile(filePath, callback) {
  let fd
  try {
    fd = await fs.open(filePath, 'a+')
    return await callback(fd)
  } finally {
    fd?.close()
  }
}

export async function formattedTodos(filePath) {
  return await useTodoFile(filePath, async (fd) => {
    const content = await fd.readFile('utf8')
    return content
      .split('\n')
      .filter((title) => title)
      .map((title, index) => {
        const isDone = /^\[\*\]/.test(title)
        const rawTitle = title.match(/^\[[\s*]\]\s(.+)/)?.[1]
        return `${index + 1} ${isDone ? strikethrough(rawTitle) : rawTitle}`
      })
      .join('\n')
  })
}

export async function addTodo(filePath, todoTitle) {
  return await useTodoFile(filePath, async (fd) => {
    fd.appendFile(`[ ] ${todoTitle}\n`)
  })
}

export async function markDone(filePath, ids) {
  return await useTodoFile(filePath, async (fd) => {
    const content = await fd.readFile('utf8')
    const lines = content.split('\n')
    ids.forEach((id) => {
      lines[id - 1] = lines[id - 1].replace(/^\[\s\]/, '[*]')
    })
    const updatedContent = lines.join('\n')
    await fd.truncate()
    await fd.writeFile(updatedContent)
  })
}

export async function clearTodos(filePath) {
  return await useTodoFile(filePath, async (fd) => {
    await fd.truncate()
  })
}

function strikethrough(text) {
  return `\x1b[9m${text}\x1b[29m`
}

main()
