import { useAccountPkh, useConnect, useOnBlock, useReady, useTezos, useWallet } from 'dapp/dapp'
import { NETWORK } from 'dapp/defaults'
import * as React from 'react'
import { useAlert } from 'react-alert'

import { HeaderView } from './Header.view'

export const Header = () => {
  const tezos = useTezos()
  const accountPkh = useAccountPkh()
  const [balance, setBalance] = React.useState(null)
  const wallet = useWallet()
  const ready = useReady()
  const connect = useConnect()
  const alert = useAlert()

  const handleConnect = React.useCallback(async () => {
    try {
      await connect(NETWORK)
    } catch (err) {
      alert.show(err.message)
      console.error(err.message)
    }
  }, [alert, connect])

  const accountPkhPreview = React.useMemo(() => {
    if (!accountPkh) return undefined
    else {
      const accPkh = (accountPkh as unknown) as string
      const ln = accPkh.length
      return `${accPkh.slice(0, 7)}...${accPkh.slice(ln - 4, ln)}`
    }
  }, [accountPkh])

  const loadBalance = React.useCallback(async () => {
    if (tezos) {
      const tezosOk = tezos as any
      const bal = await tezosOk.tz.getBalance(accountPkh)
      setBalance(tezosOk.format('mutez', 'tz', bal).toString())
    }
  }, [tezos, accountPkh, setBalance])

  React.useEffect(() => {
    loadBalance()
  }, [loadBalance])

  useOnBlock(tezos, loadBalance)

  const handleNewConnect = React.useCallback(() => {
    connect(NETWORK, { forcePermission: true })
  }, [connect])

  return (
    <HeaderView
      balance={balance}
      accountPkhPreview={accountPkhPreview}
      handleNewConnect={handleNewConnect}
      wallet={wallet}
      ready={ready}
      handleConnect={handleConnect}
    />
  )
}
