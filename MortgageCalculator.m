function MortgageCalculator
% MortgageCalculator - Programmatic UI for mortgage calculation and visualization

fig = uifigure('Name', 'Mortgage Calculator', ...
    'NumberTitle', 'off', ...
    'MenuBar', 'none', ...
    'Resize', 'off', ...
    'Position', [100 100 700 400], ...
    'Color', [0.94 0.94 0.94]); % MATLAB default gray

% --- Define Layout Constants ---
labelWidth = 120;
editWidth = 140;
rowHeight = 32;
rowSpacing = 32;
inputAreaLeft = 10;
inputAreaTop = 10;
inputAreaHeight = 380;
inputAreaWidth = 300;

% --- Calculate Centered Y Positions ---
numControls = 4; % Loan, Rate, Period, Button/Result
totalControlsHeight = numControls * rowHeight + (numControls - 1) * rowSpacing;
startY = inputAreaTop + (inputAreaHeight - totalControlsHeight) / 2 + totalControlsHeight - rowHeight;

y1 = startY;
y2 = y1 - rowHeight - rowSpacing;
y3 = y2 - rowHeight - rowSpacing;
y4 = y3 - rowHeight - rowSpacing;

% --- Create UI Components ---

% Loan Amount
loanLabel = uilabel(fig, 'Text', 'Loan Amount', ...
    'HorizontalAlignment', 'right', ...
    'BackgroundColor', [0.94 0.94 0.94], ...
    'Position', [inputAreaLeft, y1, labelWidth, rowHeight]);
loanEdit = uieditfield(fig, 'text', ...
    'Value', '300000', ...
    'Position', [inputAreaLeft + labelWidth + 10, y1, editWidth, rowHeight]);

% Add this callback function to ensure only whole numbers
loanEdit.ValueChangedFcn = @(src,event) validateLoanAmount(src);

% Interest Rate
rateLabel = uilabel(fig, 'Text', 'Interest Rate (%)', ...
    'HorizontalAlignment', 'right', ...
    'BackgroundColor', [0.94 0.94 0.94], ...
    'Position', [inputAreaLeft, y2, labelWidth, rowHeight]);
rateEdit = uieditfield(fig, 'numeric', ...
    'Value', 4, 'Limits', [0 100], ...
    'Position', [inputAreaLeft + labelWidth + 10, y2, editWidth, rowHeight]);

% Loan Period
periodLabel = uilabel(fig, 'Text', 'Loan Period (Years)', ...
    'HorizontalAlignment', 'right', ...
    'BackgroundColor', [0.94 0.94 0.94], ...
    'Position', [inputAreaLeft, y3, labelWidth, rowHeight]);
periodEdit = uieditfield(fig, 'numeric', ...
    'Value', 30, 'Limits', [1 100], ...
    'Position', [inputAreaLeft + labelWidth + 10, y3, editWidth, rowHeight]);

% Monthly Payment Button
calcBtn = uibutton(fig, 'push', 'Text', 'Monthly Payment', ...
    'Position', [inputAreaLeft, y4, labelWidth, rowHeight]);

% Monthly Payment Result
mpEdit = uieditfield(fig, 'text', 'Editable', 'off', ...
    'Value', '$0.00', 'FontSize', 16, ...
    'Position', [inputAreaLeft + labelWidth + 10, y4, editWidth, rowHeight]);

% Divider
dividerX = inputAreaLeft + inputAreaWidth + 5;
divider = uilabel(fig, 'Position', [dividerX, 10, 2, 380], ...
    'BackgroundColor', [0.8 0.8 0.8], 'Text', '');

% Axes for plot
ax = uiaxes(fig, ...
    'Position', [dividerX + 15, 40, 340, 320], ...
    'Box', 'on', ...
    'FontSize', 12, ...
    'BackgroundColor', [0.94 0.94 0.94]);
ax.XLabel.String = 'Time (Months)';
ax.YLabel.String = 'Amount';
ax.Title.String = 'Principal and Interest';

% --- Set Callback ---
calcBtn.ButtonPushedFcn = @(src, event)calculateMortgage();

    % --- Calculation Function ---
    function calculateMortgage()
        P = str2double(loanEdit.Value);  % Convert text to number
        r = rateEdit.Value / 100 / 12;
        n = periodEdit.Value * 12;
        if r == 0
            M = P / n;
        else
            M = P * (r * (1 + r)^n) / ((1 + r)^n - 1);
        end
        mpEdit.Value = sprintf('$%.2f', M);

        % Amortization schedule
        principalPaid = zeros(1, n);
        interestPaid = zeros(1, n);
        balance = P;
        for i = 1:n
            interest = balance * r;
            principal = M - interest;
            interestPaid(i) = interest;
            principalPaid(i) = principal;
            balance = balance - principal;
        end

        % Plot
        cla(ax);
        plot(ax, 1:n, principalPaid, 'b', 'LineWidth', 1.5);
        hold(ax, 'on');
        plot(ax, 1:n, interestPaid, 'r', 'LineWidth', 1.5);
        hold(ax, 'off');
        ax.XLabel.String = 'Time (Months)';
        ax.YLabel.String = 'Amount';
        ax.Title.String = 'Principal and Interest';
        legend(ax, {'Principal', 'Interest'}, 'Location', 'northwest');
        grid(ax, 'on');
    end
end

function validateLoanAmount(src)
    % Remove any non-numeric characters
    val = str2double(regexp(src.Value, '\d+', 'match', 'once'));
    if isempty(val) || isnan(val)
        val = 0;
    end
    % Update with clean number
    src.Value = num2str(val);
end
