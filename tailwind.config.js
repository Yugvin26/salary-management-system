/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/javascript/**/*.{js,jsx}",
    "./app/views/**/*.html.erb"
  ],
  theme: {
    extend: {
      colors: {
        ink: "rgb(var(--ink) / <alpha-value>)",
        clay: "rgb(var(--clay) / <alpha-value>)",
        sand: "rgb(var(--sand) / <alpha-value>)"
      },
      keyframes: {
        fadeUp: {
          "0%": { opacity: "0", transform: "translateY(10px)" },
          "100%": { opacity: "1", transform: "translateY(0)" }
        },
        pop: {
          "0%": { transform: "scale(0.98)" },
          "100%": { transform: "scale(1)" }
        },
        drift: {
          "0%, 100%": { transform: "translate3d(0, 0, 0) scale(1)" },
          "50%": { transform: "translate3d(40px, 30px, 0) scale(1.12)" }
        },
        driftReverse: {
          "0%, 100%": { transform: "translate3d(0, 0, 0) scale(1)" },
          "50%": { transform: "translate3d(-50px, 24px, 0) scale(1.08)" }
        }
      },
      animation: {
        fadeUp: "fadeUp 0.4s ease",
        pop: "pop 0.2s ease",
        drift: "drift 8s ease-in-out infinite",
        "drift-reverse": "driftReverse 10s ease-in-out infinite",
        "drift-slow": "drift 14s ease-in-out infinite"
      }
    }
  },
  plugins: []
}
