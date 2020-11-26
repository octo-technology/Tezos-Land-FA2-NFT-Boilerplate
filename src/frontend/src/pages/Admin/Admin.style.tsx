import styled from 'styled-components/macro'

export const AdminStyled = styled.div`
  margin: 100px;
  display: grid;
  grid-template-columns: 2fr 2fr 3fr 4fr 3fr ;
  grid-gap: 10px;
  width: 1250px;
  background-color: #141b43;
  position: relative;
  margin: auto;
  z-index: 2;
`

export const AdminInput = styled.input`
  height: 40px;
  width: 100%;
  background-color: #202337;
  box-sizing: border-box;
  border: 0;
  border-radius: 5px;
  font-size: 11px;

  ::placeholder {
    color: "#727272";
    font-size: 11px;
  }
`;

export const AdminButton = styled.button`
  height: 40px;
  font-size: 11px;
  width: 100%;
  background-color: #4c5170;
  box-sizing: border-box;
  border: 0;
  border-radius: 5px;
  color: #FFF;
`;