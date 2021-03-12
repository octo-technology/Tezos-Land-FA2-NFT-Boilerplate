import styled from 'styled-components/macro'
import { textColor } from 'styles'

export const HeaderStyled = styled.div`
  margin-bottom: 20px;
  position: relative;
  text-align: center;
  height: 50px;
  z-index: 1;
`

export const HeaderLogo = styled.img`
  margin-top: 13px;
  z-index: 1;
  width: 200px;
`

export const HeaderRight = styled.div`
  position: absolute;
  top: 0;
  right: 20px;
  line-height: 50px;
`

export const HeaderLeft = styled.div`
  position: absolute;
  top: 0;
  left: 30px;
  line-height: 50px;
  display: grid;
  grid-template-columns: auto auto auto auto;
  grid-gap: 40px;
  font-weight: bold;

  > a {
    display: grid;
    grid-template-columns: auto auto;
    grid-gap: 10px;
    font-weight: bold;

    svg {
      stroke: ${textColor};
      height: 22px;
      width: 22px;
      margin: 13px 3px 0 0;
    }
  }
`

export const HeaderNoWallet = styled.div`
  cursor: pointer;

  > a {
    display: grid;
    grid-template-columns: auto auto;
    grid-gap: 10px;
    font-weight: bold;

    svg {
      stroke: ${textColor};
      height: 22px;
      width: 22px;
      margin: 13px 3px 0 0;
    }
  }
`

export const HeaderConnectWallet = styled.div`
  cursor: pointer;
  display: grid;
  grid-template-columns: auto auto;
  grid-gap: 10px;
  font-weight: bold;

  svg {
    stroke: ${textColor};
    height: 22px;
    width: 22px;
    margin: 13px 3px 0 0;
  }
`

export const HeaderAccount = styled.div`
  display: grid;
  grid-template-columns: auto auto auto;
  grid-gap: 20px;

  @media (max-width: 1300px) {
    grid-template-columns: auto auto ;
    > :nth-child(3) {
      display: none;
    }
  }

  @media (max-width: 1000px) {
    grid-template-columns: auto;
    > :nth-child(1), :nth-child(3) {
      display: none;
    }
  }

`
