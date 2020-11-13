import axios from 'axios'
// import useAxios from 'axios-hooks'
import { useAccountPkh, useOnBlock, useReady, useTezos, useWallet } from 'dapp/dapp'
import { LEDGER, PLAYERS, TEZOSLAND_ADDRESS, TOKENS, TOKENS_ON_SALE } from 'dapp/defaults'
import * as React from 'react'
import { useEffect, useState } from 'react'

import { BuyStyled } from './Buy.style'
import { BuyView } from './Buy.view'

export type TokenOnSale = {
  token_id: string
  price: number
  player_id?: string
  name?: string
}

export const Buy = () => {
  const wallet = useWallet()
  const ready = useReady()
  const tezos = useTezos()
  const accountPkh = useAccountPkh()
  const [contract, setContract] = useState(undefined)
  const [tokensOnSale, setTokensOnSale] = useState<TokenOnSale[]>([])
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
        const tokensOnSaleFromStorage = storage["market"].sales
        const tokensOnSaleWithPrice = tokensOnSaleFromStorage.map((sale: { token_id: { c: any[] }; price: { c: any[] } }) => (
          {
            token_id: sale.token_id.c[0], 
            price: sale.price.c[0]
          } as TokenOnSale))
        setTokensOnSale(tokensOnSaleWithPrice)
        
      }
    })()
  }, [contract, accountPkh])

  // useOnBlock(tezos, loadStorage)

  type BuyToken = { token_id: number; price: number }
  const buyToken = React.useCallback(
    ({ token_id, price }: BuyToken) => {
      console.log(token_id, price)
      ;(contract as any).methods.buyLand(price * 1000000, token_id).send({ amount: price })
    },
    [contract],
  )

  return (
    <BuyStyled>
      {wallet ? (
        <>
          {ready ? (
            <>
              {tokensOnSale && tokensOnSale.length > 0 ? (
                <BuyView buyToken={buyToken} tokensOnSale={tokensOnSale} />
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
    </BuyStyled>
  )
}
