declare module 'y-websocket' {
  export class WebsocketProvider {
    constructor(
      serverUrl: string,
      roomname: string,
      doc: any,
      opts?: any
    )

    awareness: any
    disconnect(): void
    connect(): void
    destroy(): void
    on(event: string, handler: (...args: any[]) => void): void
  }
}

