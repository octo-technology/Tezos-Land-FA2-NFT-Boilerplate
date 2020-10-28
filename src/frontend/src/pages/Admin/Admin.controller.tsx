import { useWallet, useReady, useTezos, useOnBlock, useAccountPkh } from 'dapp/dapp'
import { TEZOSLAND_ADDRESS } from 'dapp/defaults'
import * as React from 'react'
import { useEffect, useState } from 'react'
import { AdminStyled } from './Admin.style'

import { AdminView } from './Admin.view'

export const Admin = () => {
  const wallet = useWallet()
  const ready = useReady()
  const tezos = useTezos()
  const accountPkh = useAccountPkh()
  const [contract, setContract] = useState(undefined)
  const [storage, setStorage] = useState(undefined)

  const loadStorage = React.useCallback(async () => {
    if (contract) {
      const storage = await (contract as any).storage()
      console.info(`storage: ${JSON.stringify(storage)}`)
      setStorage(storage.toString())
    }
  }, [setStorage, contract])

  useEffect(() => {
    loadStorage()
  }, [loadStorage])

  useEffect(() => {
    ;(async () => {
      if (tezos) {
        const ctr = await (tezos as any).wallet.at(TEZOSLAND_ADDRESS)
        setContract(ctr)
      }
    })()
  }, [tezos])

  useOnBlock(tezos, loadStorage)

  type AddPlayer = { amount: number; player_id: number; name: string; metadata: string }
  const addPlayer = React.useCallback(
    ({ amount, metadata, name, player_id }: AddPlayer) =>
      (contract as any).methods.addPlayer(accountPkh, amount, metadata, name, player_id).send(),
    [contract],
  )

  type Mint = { amount: number; player_id: number; token_id: number }
  const mint = React.useCallback(
    ({ amount, player_id, token_id }: Mint) =>
      (contract as any).methods.mint(accountPkh, amount, player_id, token_id).send(),
    [contract],
  )

  return (
    <AdminStyled>
      {wallet ? (
        <>
          {ready ? (
            <AdminView addPlayer={addPlayer} mint={mint} storage={storage} />
          ) : (
            <div>Please connect your wallet.</div>
          )}
        </>
      ) : (
        <div>Please install the Thanos Wallet Chrome Extension.</div>
      )}
    </AdminStyled>
  )
}
