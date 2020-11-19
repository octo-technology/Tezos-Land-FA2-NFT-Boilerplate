import axios from 'axios'
// import useAxios from 'axios-hooks'
import { useAccountPkh, useOnBlock, useReady, useTezos, useWallet } from 'dapp/dapp'
import { LEDGER, PLAYERS, TEZOSLAND_ADDRESS, TOKENS } from 'dapp/defaults'
import * as React from 'react'
import { useEffect, useState } from 'react'
import {MichelsonMap} from '@taquito/taquito'

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
      if (contract && accountPkh) {
        const storage = await (contract as any).storage()
        const tokensOwnedFromStorage = await storage.market.owners.get(accountPkh)
        if (tokensOwnedFromStorage){
          const tokensOwnedByUser = tokensOwnedFromStorage.map((token: { c: any[] }) => ({token_id: token.c[0], name: token.c[0]}))
          setMyTokens(tokensOwnedByUser)
          setLoading(false)
        } 
        
      }
    })()
  }, [contract, accountPkh])

  // useOnBlock(tezos, loadStorage)

  type SellToken = { token_id: number; price: number }
  const sellToken = React.useCallback(
    ({ token_id, price }: SellToken) => {
      console.log(token_id, price)
      ;(contract as any).methods.sellLand(price * 1000000, token_id).send()
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
