import { render, screen } from '@testing-library/react'
import { expect, test } from 'vitest'
import App from './App'

test('renders Dev-PyNode title', () => {
  render(<App />)
  const titleElement = screen.getByText(/Dev-PyNode/i)
  expect(titleElement).toBeInTheDocument()
})
