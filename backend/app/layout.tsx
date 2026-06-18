import type { ReactNode } from "react";

export const metadata = {
  title: "RoomLoot Backend",
  description: "RoomLoot API service"
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}

