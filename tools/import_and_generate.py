#!/usr/bin/env python3
"""
Sample answers from the Hugging Face `albertxu/CrosswordQA` dataset and
    # Load the generator module and fail loudly if it cannot be loaded
    gen_mod = load_generator_module(args.generator_path)

    for idx, group in enumerate(groups, start=1):
        pid = f"hf_sample_{idx}"
        title = f"HF sample {idx}"
        metadata = {"title": title, "author": "import_and_generate", "language": "en", "source_format": "crosswordqa+pycrossword"}

        print(f"Generating puzzle {idx}/{len(groups)} with {len(group)} words...")
        # Use the repository's generator; let any exceptions propagate
        puzzle = gen_mod.generate_puzzle_from_words(
            words=group,
            max_width=21,
            max_height=21,
            seed=args.seed,
            puzzle_id=pid,
            metadata=metadata,
            clue_generator=None,
        )

        outpath = Path(args.outdir) / f"puzzle_{pid}.json"
        with open(outpath, "w", encoding="utf-8") as f:
            if args.pretty:
                json.dump(puzzle, f, ensure_ascii=False, indent=2)
            else:
                json.dump(puzzle, f, ensure_ascii=False)

        print(f"Saved puzzle to: {outpath} ({puzzle.get('cols')}x{puzzle.get('rows')}) placed {len(puzzle.get('entries', []))} words")

    print("Done.")
                    if x + wlen <= W:
                        conflict = False
                        overlap = 0
                        for i, ch in enumerate(word):
                            cell = grid[y][x + i]
                            if cell is None:
                                continue
                            if cell == ch:
                                overlap += 1
                            else:
                                conflict = True
                                break
                        if not conflict:
                            # ensure at least one overlap (prefer) or allow 0 if nothing else
                            score = overlap
                            if score > best_score:
                                best_score = score
                                best = (word, y, x, True, score)
                    # vertical
                    if y + wlen <= H:
                        conflict = False
                        overlap = 0
                        for i, ch in enumerate(word):
                            cell = grid[y + i][x]
                            if cell is None:
                                continue
                            if cell == ch:
                                overlap += 1
                            else:
                                conflict = True
                                break
                        if not conflict:
                            score = overlap
                            if score > best_score:
                                best_score = score
                                best = (word, y, x, False, score)

            if best is None:
                # skip word if cannot place
                continue
            w, yy, xx, is_horiz, sc = best
            if is_horiz:
                for i, ch in enumerate(w):
                    grid[yy][xx + i] = ch
            else:
                for i, ch in enumerate(w):
                    grid[yy + i][xx] = ch
            placed.append((w, yy, xx, is_horiz))

        return ((W, H), placed)

    for idx, group in enumerate(groups, start=1):
        pid = f"hf_sample_{idx}"
        title = f"HF sample {idx}"
        metadata = {"title": title, "author": "import_and_generate", "language": "en", "source_format": "crosswordqa+pycrossword"}

        print(f"Generating puzzle {idx}/{len(groups)} with {len(group)} words...")
        puzzle = None
        if gen_mod is not None:
            try:
                # pass a reasonable default size to avoid generator edge-cases
                puzzle = gen_mod.generate_puzzle_from_words(
                    words=group,
                    max_width=21,
                    max_height=21,
                    seed=args.seed,
                    puzzle_id=pid,
                    metadata=metadata,
                    clue_generator=None,
                )
            except Exception as e:
                print(f"Generator failed for puzzle {idx}: {e}")
                puzzle = None

        if puzzle is None:
            # Use simple packer
            dims, placed = simple_packer(group, max_width=21, max_height=21)
            (cols, rows) = dims
            # build cells and entries similar to pycrossword_to_canonical
            cells = []
            for y in range(rows):
                for x in range(cols):
                    ch = None
                    # find char in grid placed above
                    # we reconstructed grid implicitly in packer so rebuild
                    cells.append({"x": x, "y": y, "is_black": True, "solution": None})

            # create a temporary grid and fill from placed
            grid = [[None for _ in range(cols)] for _ in range(rows)]
            for word, row, col, is_h in placed:
                for i, ch in enumerate(word):
                    if is_h:
                        grid[row][col + i] = ch
                    else:
                        grid[row + i][col] = ch

            # update cells with grid
            cells = []
            for y in range(rows):
                for x in range(cols):
                    val = grid[y][x]
                    cells.append({"x": x, "y": y, "is_black": (val is None), "solution": (val if val is not None else None)})

            entries = []
            number_map = {}
            current_number = 1
            for y in range(rows):
                for x in range(cols):
                    if cells[y * cols + x]["is_black"]:
                        continue
                    is_start_across = (x == 0 or cells[y * cols + (x - 1)]["is_black"]) and (x < cols - 1 and not cells[y * cols + (x + 1)]["is_black"])
                    is_start_down = (y == 0 or cells[(y - 1) * cols + x]["is_black"]) and (y < rows - 1 and not cells[(y + 1) * cols + x]["is_black"]) 
                    if is_start_across or is_start_down:
                        number_map[f"{y},{x}"] = current_number
                        current_number += 1

            for word, row, col, is_h in placed:
                direction = "across" if is_h else "down"
                number = number_map.get(f"{row},{col}", 0)
                length = len(word)
                entries.append({
                    "id": f"{direction[0]}{number}",
                    "number": number,
                    "direction": direction,
                    "x": col,
                    "y": row,
                    "length": length,
                    "answer": word,
                    "clue": f"Imported from CrosswordQA"
                })

            entries.sort(key=lambda e: (e["number"], 0 if e["direction"] == "across" else 1))

            puzzle = {
                "id": pid,
                "version": "1.0",
                "metadata": metadata,
                "rows": rows,
                "cols": cols,
                "cells": cells,
                "entries": entries
            }

        outpath = Path(args.outdir) / f"puzzle_{pid}.json"
        with open(outpath, "w", encoding="utf-8") as f:
            if args.pretty:
                json.dump(puzzle, f, ensure_ascii=False, indent=2)
            else:
                json.dump(puzzle, f, ensure_ascii=False)

        print(f"Saved puzzle to: {outpath} ({puzzle.get('cols')}x{puzzle.get('rows')}) placed {len(puzzle.get('entries', []))} words")

    print("Done.")


if __name__ == "__main__":
    main()
