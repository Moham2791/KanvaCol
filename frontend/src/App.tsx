import { useEffect, useRef, useState } from "react";
import { Excalidraw } from "@excalidraw/excalidraw";
import "@excalidraw/excalidraw/index.css";

const CANVAS_ID = 1; // later: from the URL or the logged-in user

export default function App() {
  const [initialData, setInitialData] = useState<any>(null);
  const saveTimer = useRef<number | undefined>(undefined);

  // Load the saved drawing when the app opens
  useEffect(() => {
    fetch(`/api/canvas/${CANVAS_ID}`)
        .then((r) => (r.ok ? r.json() : null))
        .then((c) => setInitialData(c ? JSON.parse(c.scene) : { elements: [] }))
        .catch(() => setInitialData({ elements: [] }));
  }, []);

  // Auto-save 1 second after the user stops drawing
  const handleChange = (elements: readonly any[], appState: any) => {
    window.clearTimeout(saveTimer.current);
    saveTimer.current = window.setTimeout(() => {
      const scene = JSON.stringify({
        elements,
        appState: { viewBackgroundColor: appState.viewBackgroundColor },
      });
      fetch(`/api/canvas/${CANVAS_ID}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ scene }),
      });
    }, 1000);
  };

  if (!initialData) return <div>Loading…</div>;

  return (
      <div style={{ height: "100vh", width: "100vw" }}>
        <Excalidraw initialData={initialData} onChange={handleChange} />
      </div>
  );
}