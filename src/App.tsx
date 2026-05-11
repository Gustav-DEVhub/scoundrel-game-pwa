import './App.css'

function App() {
  return (
    <main className="app-shell" aria-label="Scoundrel game">
      <iframe
        className="app-shell__iframe"
        src="/scoundrel/index.html"
        title="Scoundrel game"
        allow="autoplay"
      />
    </main>
  )
}

export default App
