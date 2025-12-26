import pandas as pd
import numpy as np
from pathlib import Path


def calculate_pwsv_lwsr():

    base_dir = Path(__file__).resolve().parent.parent

    table1_path = base_dir / 'data' / 'sector_water_output' / '2012.xlsx'

    ww_path  = base_dir / 'data' / 'city_water' / '2012_water_withdrawal.xlsx'
    wa_path  = base_dir / 'data' / 'city_water' / '2012_water_availability.xlsx'
    bod_path = base_dir / 'data' / 'city_water' / '2012_bod.xlsx'

    output_pwsv_path = base_dir / 'results' / 'pwsv_sector' / '2012_pwsv_sector.xlsx'
    output_lwsr_path = base_dir / 'results' / 'lwsr_sector' / '2012_lwsr_sector.xlsx'

    EFR = 0.8

    df1 = pd.read_excel(
        table1_path,
        usecols=['water withdrawal', 'output'],
        header=0
    )

    ww  = pd.read_excel(ww_path,  header=None).iloc[:, 0].values
    wa  = pd.read_excel(wa_path,  header=None).iloc[:, 0].values
    bod = pd.read_excel(bod_path, header=None).iloc[:, 0].values

    if len(df1) != 313 * 42:
        raise ValueError(f'Invalid row number in sector table: {len(df1)}')

    if not (len(ww) == len(wa) == len(bod) == 313):
        raise ValueError('City-level input files must all have 313 rows')

    DW = np.zeros(313)
    mask = bod > 2
    DW[mask] = (bod[mask] / 2 - 1) * ww[mask]

    city_pwsv = ww - wa * (1 - EFR) + DW

    dept_pwsv = np.zeros(313 * 42)
    dept_lwsr = np.zeros(313 * 42)

    for city_idx in range(313):

        start = city_idx * 42
        end = start + 42

        water_use   = df1.iloc[start:end, 0].values
        econ_output = df1.iloc[start:end, 1].values

        intensity = water_use / econ_output

        total_pwsv = city_pwsv[city_idx]

        depts = list(zip(intensity, water_use, econ_output, range(42)))
        depts_sorted = sorted(depts, key=lambda x: (-x[0], x[1]))

        remaining = total_pwsv

        for inten, water, econ, idx_local in depts_sorted:

            if remaining <= 0:
                break

            global_idx = start + idx_local

            if water <= remaining:
                dept_pwsv[global_idx] = water
                dept_lwsr[global_idx] = econ
                remaining -= water
            else:
                dept_pwsv[global_idx] = remaining
                dept_lwsr[global_idx] = (remaining / water) * econ
                remaining = 0
                break

    output_pwsv_path.parent.mkdir(parents=True, exist_ok=True)
    output_lwsr_path.parent.mkdir(parents=True, exist_ok=True)

    pd.DataFrame(dept_pwsv).to_excel(output_pwsv_path, index=False, header=False)
    pd.DataFrame(dept_lwsr).to_excel(output_lwsr_path, index=False, header=False)


if __name__ == "__main__":
    calculate_pwsv_lwsr()
