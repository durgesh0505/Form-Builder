export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <div className="z-10 max-w-5xl w-full items-center justify-center font-mono text-sm">
        <div className="text-center">
          <h1 className="text-6xl font-bold mb-4 bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
            🐰 Rabbit Forms
          </h1>
          <p className="text-xl text-muted-foreground mb-8">
            Complete Form Builder SaaS Solution
          </p>
          <div className="flex gap-4 justify-center">
            <a
              href="/login"
              className="inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 bg-primary text-primary-foreground hover:bg-primary/90 h-10 px-4 py-2"
            >
              Get Started
            </a>
            <a
              href="https://github.com/durgesh0505/Form-Builder"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 border border-input bg-background hover:bg-accent hover:text-accent-foreground h-10 px-4 py-2"
            >
              View on GitHub
            </a>
          </div>
        </div>

        <div className="mt-16 grid grid-cols-1 md:grid-cols-3 gap-8">
          <div className="p-6 border rounded-lg">
            <h3 className="text-lg font-semibold mb-2">🎨 Drag & Drop Builder</h3>
            <p className="text-sm text-muted-foreground">
              Create beautiful forms with our intuitive visual builder
            </p>
          </div>
          <div className="p-6 border rounded-lg">
            <h3 className="text-lg font-semibold mb-2">⚡ Conditional Logic</h3>
            <p className="text-sm text-muted-foreground">
              Build smart forms with IF-THEN rules and database lookups
            </p>
          </div>
          <div className="p-6 border rounded-lg">
            <h3 className="text-lg font-semibold mb-2">📊 Analytics</h3>
            <p className="text-sm text-muted-foreground">
              Track submissions, completion rates, and export data
            </p>
          </div>
        </div>

        <div className="mt-16 text-center">
          <p className="text-sm text-muted-foreground">
            Open-source and free to use. Built with Next.js and Supabase.
          </p>
        </div>
      </div>
    </main>
  )
}
