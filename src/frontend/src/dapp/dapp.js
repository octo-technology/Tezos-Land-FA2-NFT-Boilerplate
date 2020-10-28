import React from 'react'
import constate from 'constate'
import { ThanosWallet } from '@thanos-wallet/dapp'

export const [DAppProvider, useWallet, useTezos, useAccountPkh, useReady, useConnect] = constate(
  useDApp,
  (v) => v.wallet,
  (v) => v.tezos,
  (v) => v.accountPkh,
  (v) => v.ready,
  (v) => v.connect,
)

function useDApp({ appName }) {
  const [{ wallet, tezos, accountPkh }, setState] = React.useState(() => ({
    wallet: undefined,
    tezos: undefined,
    accountPkh: undefined,
  }))

  const ready = Boolean(tezos)

  React.useEffect(() => {
    return ThanosWallet.onAvailabilityChange((available) => {
      setState({
        wallet: available ? new ThanosWallet(appName) : undefined,
        tezos: undefined,
        accountPkh: undefined,
      })
    })
  }, [setState, appName])

  const connect = React.useCallback(
    async (network, opts) => {
      try {
        if (!wallet) {
          throw new Error('Thanos Wallet not available')
        }
        await wallet.connect(network, opts)
        const tzs = wallet.toTezos()
        const pkh = await tzs.wallet.pkh()
        setState({
          wallet,
          tezos: tzs,
          accountPkh: pkh,
        })
      } catch (err) {
        alert(`Failed to connect ThanosWallet: ${err.message}`)
      }
    },
    [setState, wallet],
  )

  return {
    wallet,
    tezos,
    accountPkh,
    ready,
    connect,
  }
}

export function useOnBlock(tezos, callback) {
  const blockHashRef = React.useRef()

  React.useEffect(() => {
    if (tezos) {
      let sub
      spawnSub()
      return () => sub.close()

      function spawnSub() {
        sub = tezos.stream.subscribe('head')

        sub.on('data', (hash) => {
          if (blockHashRef.current && blockHashRef.current !== hash) {
            callback(hash)
          }
          blockHashRef.current = hash
        })
        sub.on('error', (err) => {
          if (process.env.NODE_ENV === 'development') {
            console.error(err)
          }
          sub.close()
          spawnSub()
        })
      }
    }
  }, [tezos, callback])
}
