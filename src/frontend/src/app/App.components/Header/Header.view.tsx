import * as React from 'react'
import { Link } from 'react-router-dom'

// prettier-ignore
import { HeaderAccount, HeaderConnectWallet, HeaderLeft, HeaderLogo, HeaderNoWallet, HeaderRight, HeaderStyled } from "./Header.style";

type HeaderViewProps = {
  balance?: number | null
  accountPkhPreview?: string
  handleNewConnect: () => void
  wallet: any
  ready: boolean
  handleConnect: () => void
}

export const HeaderView = ({
  balance,
  accountPkhPreview,
  handleNewConnect,
  wallet,
  ready,
  handleConnect,
}: HeaderViewProps) => {
  return (
    <HeaderStyled>
      <HeaderLeft>
        <Link to="/buy">
          <svg>
            <use xlinkHref="/icons/sprites.svg#buy" />
          </svg>
          <div>BUY</div>
        </Link>
        <Link to="/sell">
          <svg>
            <use xlinkHref="/icons/sprites.svg#sell" />
          </svg>
          <div>SELL</div>
        </Link>
        <Link to="/map">
          <svg>
            <use xlinkHref="/icons/sprites.svg#map" />
          </svg>
          <div>MAP</div>
        </Link>
        <Link to="/help">
          <svg>
            <use xlinkHref="/icons/sprites.svg#help" />
          </svg>
          <div>HELP</div>
        </Link>
      </HeaderLeft>

      <Link to="/">
        <HeaderLogo alt="logo" src="/logo.svg" />
      </Link>

      <HeaderRight>
        {wallet ? (
          <>
            {ready ? (
              <HeaderAccount>
                <div>Account : {accountPkhPreview}</div>
                <div>Balance : {balance} XTZ</div>
                <HeaderConnectWallet onClick={handleNewConnect}>
                  <svg>
                    <use xlinkHref="/icons/sprites.svg#wallet" />
                  </svg>
                  <div>CHANGE ACCOUNT</div>
                </HeaderConnectWallet>
              </HeaderAccount>
            ) : (
              <HeaderConnectWallet onClick={handleConnect}>
                <svg>
                  <use xlinkHref="/icons/sprites.svg#wallet" />
                </svg>
                <div>CONNECT WALLET</div>
              </HeaderConnectWallet>
            )}
          </>
        ) : (
          <HeaderNoWallet>
            <a href="https://thanoswallet.com" target="_blank" rel="noopener noreferrer">
              <svg>
                <use xlinkHref="/icons/sprites.svg#wallet" />
              </svg>
              <div>INSTALL WALLET</div>
            </a>
          </HeaderNoWallet>
        )}
      </HeaderRight>
    </HeaderStyled>
  )
}
