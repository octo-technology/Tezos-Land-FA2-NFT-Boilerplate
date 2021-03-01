import styled from "styled-components/macro";

export const SellLandMapStyled = styled.div`
  height: 500px;
  width: 500px;
  display: grid;
  grid-template-columns: repeat(10, 1fr);

  > :nth-child(1) {
    border-radius: 10px 0 0 0;
  }

  > :nth-child(10) {
    border-radius: 0 10px 0 0;
  }
`;

export const SellLandMapTile = styled.div<{ selected?: boolean; isOwned: boolean }>`
  height: 50px;
  width: 50px;
  border: ${(props) => (props.selected ? "1px solid #FFFFFF" : "1px solid #141b43 ")};
  background-color: ${(props) => (props.isOwned ? "#E50000" : "#202337")};

  > img {
    display: inline-block;
    width: 24px;
    height: 24px;
    margin: 13px;
  }
`;
