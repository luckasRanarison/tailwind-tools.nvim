import React from "react"

import { ClickIcon } from "../icons"

const Component = () => {
  return (
    <div className="w-screen h-screen flex items-center justify-center container">
      <button
        onClick={() => console.log("Hello")}
        className="py-2 px-4 flex items-center 
        bg-blue-500 text-white rounded-md"
      >
        <ClickIcon className="mr-2" />
        <span className="font-semibold">Clike me</span>
      </button>
    </div>
  )
}

export default Component
