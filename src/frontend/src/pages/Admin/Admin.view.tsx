import * as React from 'react'

type AdminViewProps = {
  addPlayer: ({}: any) => void
  mint: ({}: any) => void
  storage: any
}

export const AdminView = ({ addPlayer, mint, storage }: AdminViewProps) => {
  return (
    <>
      <div
        onClick={() =>
          addPlayer({
            amount: 1,
            player_id: 15,
            name: '437',
            metadata: '',
          })
        }
      >
        Add Player
      </div>
      <div
        onClick={() =>
          mint({
            amount: 1,
            player_id: 15,
            token_id: 15,
          })
        }
      >
        Mint
      </div>
    </>
  )
}
