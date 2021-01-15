import styled from 'styled-components/macro'
import { textColor } from 'styles'

export const HomeStyled = styled.div``

export const HomeHeader = styled.div`
  height: 100vh;
  width: 100%;
  max-width: 1280px;
  margin: auto;

  @media (max-width: 600px) {
    height: initial;
  }
`

export const HomeHeaderGrid = styled.div`
  display: grid;
  grid-template-columns: 1fr 1fr;
  grid-gap: 10px;

  @media (max-width: 600px) {
    grid-template-columns: auto;
  }
`

export const HomeHeaderLeft = styled.div`
  z-index: 1;
  margin: calc(50vh - 250px) 0 0 50px;

  > h1 {
    margin: 7px 0px;
  }

  > p {
    font-size: 16px;
    margin-bottom: 16px;
  }

  > a > div {
    width: 240px;
    margin-top: 10px;
  }

  @media (max-width: 600px) {
    margin: calc(50vh - 200px) 20px;
  }
`

export const HomeHeaderRight = styled.div`
  transform: scale(1.5);
  text-align: center;
  position: relative;
  width: 200px;
  margin: calc(50vh - 270px) auto 0 auto;
  height: 200px;

  > img {
    width: 100%;
  }
`

export const HomeButton = styled.div`
  font-size: 14px;
  width: 100%;
  height: 40px;
  position: relative;
  display: inline-block;
  cursor: pointer;
  margin: 0 auto;

  img {
    display: inline-block;
    margin: 10px 20px 10px -10px;
    vertical-align: bottom;
  }

  &.abs {
    margin: 0;
    position: absolute;
    bottom: 20px;
    left: 25px;
    z-index: 1;
  }
`

export const HomeButtonBorder = styled.div`
  position: absolute;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  border: 1px solid transparent;
  border-image-source: url('/elements/button-border.svg');
  border-image-slice: 24 28 fill;
  border-image-width: 100px;
  content: '';
  z-index: 0;
`

export const HomeButtonText = styled.div`
  position: absolute;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  line-height: 40px;
  z-index: 1;
  color: ${textColor};
  text-align: center;

  > svg {
    stroke: ${textColor};
    width: 22px;
    height: 22px;
    margin-right: 17px;
    vertical-align: text-bottom;
  }
`


export const HomeHeaderButtons = styled.div`
  display: grid;
  grid-template-columns: auto auto;
  grid-gap: 20px;
`

