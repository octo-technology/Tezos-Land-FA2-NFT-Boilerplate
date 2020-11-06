from os.path import dirname, join

administrator = "tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z"
alice = "tz1L738ifd66ah69PrmKAZzckvvHnbcSeqjf"
bob = "tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v"
frank = "tz1Qd971cetwNr5f4oKp9xno6jBvghZHRsDr"
pascal = "tz1TgK3oaBaqcCHankT97AUNMjcs87Tfj5vb"
jacob = "tz1VphG4Lgp39MfQ9rTUnsm7BBWyXeXnJSMZ"
lucina = "tz1ZAZo1xW4Veq5t7YqWy2SMbLdskmeBmzqs"
mark = "tz1ccWCuJqMxG4hoa1g5SKhgdTwXoJBM8kpc"
jean = "tz1hQzKQpprB5JhNxZZRowEDRBoieHRAL84b"
boby = "tz1hTic2GpaNumpTtYwqyPSBd9KcWifRMuEN"
bartholome = "tz1hv9CrgtaxiCayc567KUvCyWDQRF9sVNuf"
lucas = "tz1iWMsg4UNSSQNKYsiH5s2maUZ9xBwymXxR"
contract_address = "KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi"

path_to_michelson_contract = join(dirname(dirname(__file__)), 'test/land.tz')


def get_storage(self, lands=None, admin=administrator, height=10, width=10,
                on_sale=None, ledger=None, operators=None):
    if operators is None:
        operators = {}
    if ledger is None:
        ledger = {}
    if on_sale is None:
        on_sale = {}
    if lands is None:
        lands = {}
    return {"market": {"lands": lands,
                       "admin": admin,
                       "height": height, "width": width,
                       "on_sale": on_sale},
            "ledger": ledger,
            "operators": operators,
            "metadata": {"token_defs": [{"from_": 1, "to_": 100}],
                         "last_used_id": 1,
                         "metadata": {(1, 100): {"token_id": 1,
                                                 "symbol": "TLD",
                                                 "name": "TezosLand",
                                                 "decimals": 0,
                                                 "extras": {}
                                                 }
                                      }}
            }