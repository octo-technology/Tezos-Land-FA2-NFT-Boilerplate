import styled from 'styled-components/macro'

export const BuyStyled = styled.div`
  margin: 30px;
  position: relative;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  grid-gap: 30px;
`

export const BuyToken = styled.div`
  position: relative;
`

export const BuyTokenGrid = styled.div`
  display: grid;
  grid-template-columns: 2fr 3fr;
  grid-gap: 10px;
  width: 240px;
  position: relative;
  margin: auto;
  z-index: 2;

  > div {
    line-height: 40px;
  }
`
