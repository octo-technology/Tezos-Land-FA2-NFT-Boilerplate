import React from 'react';
import './Counter.css';

import usePromise from 'react-promise-suspense';
import { useTezos, useOnBlock } from './dapp';

const fetchContract = (tezos, address) => tezos.wallet.at(address);

function Counter({ contractAddress }) {
  const tezos = useTezos();
  const counter = usePromise(fetchContract, [tezos, contractAddress]);
  const [storage, setStorage] = React.useState(null);

  const loadStorage = React.useCallback(async () => {
    const storage = await counter.storage();
    setStorage(storage.toString());
  }, [setStorage, counter]);

  // Load initial
  React.useEffect(() => {
    loadStorage();
  }, [loadStorage]);

  // Reload when new block
  useOnBlock(tezos, loadStorage);

  const increment = React.useCallback(
    (value) => counter.methods.increment(value).send(),
    [counter]
  );

  const decrement = React.useCallback(
    (value) => counter.methods.decrement(value).send(),
    [counter]
  );

  /**
   * UI
   */

  const [volume, setVolume] = React.useState(1);
  const [operation, setOperation] = React.useState(null);

  const processingRef = React.useRef(false);
  const processOperation = React.useCallback(
    async (factory) => {
      if (processingRef.current) return;
      processingRef.current = true;

      try {
        const op = await factory();
        setOperation(op);
      } catch (err) {
        alert(err.message);
      }

      processingRef.current = false;
    },
    [setOperation]
  );

  const handleVolumeFieldChange = React.useCallback(
    (evt) => {
      const valNum = +evt.target.value;
      if (Number.isSafeInteger(valNum)) {
        setVolume(valNum);
      }
    },
    [setVolume]
  );

  const handleIncrementClick = React.useCallback(
    () => processOperation(() => increment(volume)),
    [processOperation, increment, volume]
  );

  const handleDecrementClick = React.useCallback(
    () => processOperation(() => decrement(volume)),
    [processOperation, decrement, volume]
  );

  const count = storage;

  return (
    <div
      style={{
        display: 'flex',
        flexFlow: 'column',
        alignItems: 'center',
        justifyContent: 'space-around',
        minHeight: 300,
      }}
    >
      <div
        className="nes-badge is-splited"
        href="#"
        style={{ transform: 'scale(1.5)', marginTop: '1rem', minWidth: '64%' }}
      >
        <span className="is-success">Count: </span>
        <span className="is-primary">{count}</span>
      </div>

      <div
        style={{
          display: 'flex',
          flexFlow: 'column',
          alignItems: 'center',
          justifyContent: 'space-around',
          minHeight: 200,
        }}
      >
        <div className="nes-field is-inline">
          <label htmlFor="warning_field">Value: </label>
          <input
            id="warning_field"
            className="nes-input is-warning"
            placeholder="8bit.css"
            type="text"
            value={volume}
            onChange={handleVolumeFieldChange}
          />
        </div>

        <div className="nes-field">
          <button
            type="button"
            className="nes-btn"
            onClick={handleIncrementClick}
          >
            Increment
          </button>

          <button
            type="button"
            className="nes-btn"
            onClick={handleDecrementClick}
          >
            Decrement
          </button>
        </div>
      </div>

      {operation && <p>Operation hash: {operation.opHash}</p>}
    </div>
  );
}

export default Counter;
