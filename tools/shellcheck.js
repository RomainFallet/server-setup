import { glob } from 'glob'
import * as path from 'node:path'
import { shellcheck } from 'shellcheck'

import * as utilities from './utilities.js'

const globPattern = path.join(utilities.getBasePath(), utilities.getFirstArgument())
const paths = await glob(globPattern)

console.log('Running ShellCheck...')

const result = await shellcheck({ args: paths })

const error = result.stdout.toString('utf8').trim()
if (error.length > 0) {
  console.error(error)
  process.exit(1)
}

console.log('ShellCheck was run successfully!')
