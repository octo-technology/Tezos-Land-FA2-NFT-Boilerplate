import axios from 'axios'
// import useAxios from 'axios-hooks'
import { useAccountPkh, useOnBlock, useReady, useTezos, useWallet } from 'dapp/dapp'
import { LEDGER, PLAYERS, TEZOSLAND_ADDRESS, TOKENS } from 'dapp/defaults'
import * as React from 'react'
import { useEffect, useState } from 'react'

import { SellStyled } from './Sell.style'
import { SellView } from './Sell.view'

export type Token = {
  token_id: string
  player_id?: string
  name?: string
}

export const Sell = () => {
  const wallet = useWallet()
  const ready = useReady()
  const tezos = useTezos()
  const accountPkh = useAccountPkh()
  const [contract, setContract] = useState(undefined)
  const [myTokens, setMyTokens] = useState<Token[]>([])
  const [loading, setLoading] = useState<boolean>(true)

  // const [storage, setStorage] = useState(undefined)
  // const [{ data, loading, error }, refetch] = useAxios(
  //   `https://api.tzstats.com/explorer/bigmap/${LEDGER}/values`,
  // )
  // const myTokens: any[] = data?.filter((ledger: any) => (ledger.key = accountPkh))?.[0]?.value?.['0@set']

  // const loadStorage = React.useCallback(async () => {
  //   if (contract) {
  //     const storage = await (contract as any).storage()
  //     console.info(`storage: ${JSON.stringify(storage)}`)
  //     setStorage(storage.toString())
  //   }
  // }, [setStorage, contract])

  // useEffect(() => {
  //   loadStorage()
  // }, [loadStorage])

  useEffect(() => {
    ;(async () => {
      if (tezos) {
        const ctr = await (tezos as any).wallet.at(TEZOSLAND_ADDRESS)
        setContract(ctr)
      }
    })()
  }, [tezos])

  useEffect(() => {
    ;(async () => {
      const myTokens: Token[] = []
      if (accountPkh) {
        axios({
          method: 'get',
          url: `https://cors-anywhere.herokuapp.com/https://api.tzstats.com/explorer/bigmap/${LEDGER}/values`,
          headers: {
            'Content-Type': 'application/json',
          },
        }).then(function (response) {
          const ledger: any[] = response.data?.filter((ledger: any) => ledger.key === accountPkh)?.[0]?.value?.['0@set']
          if (ledger) {
            ledger.forEach(
              (legderEl, i) => (myTokens[i] = { token_id: legderEl, player_id: undefined, name: undefined }),
            )
            axios({
              method: 'get',
              url: `https://cors-anywhere.herokuapp.com/https://api.tzstats.com/explorer/bigmap/${TOKENS}/values`,
              headers: {
                'Content-Type': 'application/json',
              },
            }).then(function (response) {
              const tokens = response.data
              myTokens.forEach((myToken) => {
                const player_id = tokens.filter((token: any) => token.value.token_id === myToken.token_id)?.[0]?.value
                  ?.player_id
                if (player_id) myToken.player_id = player_id
              })
              axios({
                method: 'get',
                url: `https://cors-anywhere.herokuapp.com/https://api.tzstats.com/explorer/bigmap/${PLAYERS}/values`,
                headers: {
                  'Content-Type': 'application/json',
                },
              }).then(function (response) {
                const players = response.data
                myTokens.forEach((myToken) => {
                  const name = players.filter((player: any) => player.value.player_id === myToken.player_id)?.[0]?.value
                    ?.name
                  if (name) myToken.name = name
                })
                setMyTokens(myTokens)
                setLoading(false)
              })
            })
          }
        })
      }
    })()
  }, [accountPkh])

  // useOnBlock(tezos, loadStorage)

  type SellToken = { token_id: number; price: number }
  const sellToken = React.useCallback(
    ({ token_id, price }: SellToken) => {
      console.log(token_id, price)
      ;(contract as any).methods.sellToken(price * 1000000, token_id).send()
    },
    [contract],
  )

  return (
    <SellStyled>
      {wallet ? (
        <>
          {ready ? (
            <>
              {myTokens && myTokens.length > 0 ? (
                <SellView sellToken={sellToken} myTokens={myTokens} />
              ) : (
                <div>{loading ? <div>Loading lands... Please wait.</div> : <div>No land available</div>}</div>
              )}
            </>
          ) : (
            <div>Please connect your wallet.</div>
          )}
        </>
      ) : (
        <div>Please install the Thanos Wallet Chrome Extension.</div>
      )}
    </SellStyled>
  )
}
