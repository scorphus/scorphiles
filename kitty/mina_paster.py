from mina import main as mina
from mina.clipboard import copy_text


def main(args):
    tokens = mina.load_tokens()
    if tokens:
        return mina.gen_otp(tokens[int(1)])
    return "🤷🏻‍♂️"


def handle_result(args, mfa_code, target_window_id, boss):
    try:
        w = boss.window_id_map.get(target_window_id)
        if "copy" in args:
            return copy_text(mfa_code)
        if w is not None:
            w.paste(mfa_code)
    except Exception as e:
        w.paste(f"# {str(e)}")


if __name__ == "__main__":
    print(main([]))
