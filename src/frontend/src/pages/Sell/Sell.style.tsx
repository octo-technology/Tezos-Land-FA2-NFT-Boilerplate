import styled from 'styled-components/macro'

export const SellStyled = styled.div`
  margin: 30px;
  position: relative;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  grid-gap: 30px;
`

export const SellToken = styled.div`
  position: relative;
`

export const SellTokenGrid = styled.div`
  display: grid;
  grid-template-columns: 2fr 3fr;
  grid-gap: 10px;
  width: 240px;
  position: relative;
  margin: auto;
  z-index: 2;
`
