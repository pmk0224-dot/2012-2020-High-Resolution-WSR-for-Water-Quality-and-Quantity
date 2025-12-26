%%
n_cities  = 313;
n_sectors = 42;

m_city = zeros(n_cities, n_cities);

for i = 1:n_cities
    row_start = n_sectors * (i - 1) + 1;
    row_end   = n_sectors * i;

    for j = 1:n_cities
        col_start = n_sectors * (j - 1) + 1;
        col_end   = n_sectors * j;

        city_block = VWSR(row_start:row_end, col_start:col_end);
        m_city(i, j) = sum(city_block(:));
    end

    fprintf('Progress: %d / %d\n', i, n_cities);
end

%%
total_imports = sum(m_city, 1)';
self_supply   = diag(m_city);
net_imports   = total_imports - self_supply;

%%
Vul_index = zeros(n_cities, 1);

for k = 1:n_cities
    if net_imports(k) <= 0
        Vul_index(k) = 0;
    else
        imports_from_others = m_city(:, k);
        imports_from_others(k) = 0;
        import_shares = imports_from_others / net_imports(k);
        Vul_index(k) = sum(import_shares .^ 2);
    end
end

%%
fprintf('\nVulnerability index statistics:\n');
fprintf('Min  : %.6f\n', min(Vul_index));
fprintf('Max  : %.6f\n', max(Vul_index));
fprintf('Mean : %.6f\n', mean(Vul_index));

if any(Vul_index < 0 | Vul_index > 1)
    fprintf('Warning: values outside [0,1]\n');
    abnormal_idx = find(Vul_index < 0 | Vul_index > 1);
    fprintf('Abnormal count: %d\n', numel(abnormal_idx));

    for ii = 1:min(5, numel(abnormal_idx))
        idx = abnormal_idx(ii);
        fprintf('City %d: Index = %.4f, Net imports = %.2f\n', ...
                idx, Vul_index(idx), net_imports(idx));
    end
else
    fprintf('All values within [0,1]\n');
end

