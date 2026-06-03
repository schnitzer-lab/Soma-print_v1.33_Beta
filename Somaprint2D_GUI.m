function app = Somaprint2D_GUI()
% Somaprint2D_GUI
% Wizard-style GUI for the 2D Soma-print workflow.

pkgRoot = fileparts(mfilename('fullpath'));
addpath(genpath(pkgRoot));

state = initializeState();
app = initializeApp();

buildUI();
refreshAll();

    function s = initializeState()
        s.currentStep = 1;
        s.completedStep = 0;
        s.rootFolder = pwd;
        s.files = struct('invivoImage', '', 'invivoROI', '', 'exvivoImage', '', 'exvivoROI', '');
        s.map1 = [];
        s.map2 = [];
        s.image1 = [];
        s.image2 = [];
        s.image2Multi = [];
        s.tform = [];
        s.map2Tform = [];
        s.image2Tform = [];
        s.anchorPairs = zeros(0, 4);
        s.pickMode = false;
        s.pendingPair = [];
        s.pendingPairIndex = [];
        s.pendingSide = "invivo";
        s.option = GetDefaultOption();
        s.scoreWeighted = {};
        s.idMap1 = {};
        s.idMap2 = {};
        s.scoreRaw = {};
        s.iterSummary = table();
        s.somaLog = {'Run Soma-print to view algorithm messages here.'};
        s.uploadLog = {'Choose the 4 files above, then click Load files.'};
        s.outputFolder = pwd;
        s.inspect = struct('id1', [], 'id2', [], 'outputSummary', [], ...
            'optionOutput', struct(), 'secondbest', [], 'AUC', NaN, ...
            'finalIter', [], 'isReady', false );
    end

    function a = initializeApp()
        a = struct();
        a.fig = [];
        a.pageStack = [];
        a.page1 = [];
        a.page2 = [];
        a.page3 = [];
        a.page4 = [];
        a.stepButtons = gobjects(1, 4);
        a.inspectAxes = gobjects(1, 6);
        a.logoAxes = [];
        a.logoAxesAlign = [];
        a.logoAxesSoma = [];
        a.logoAxesInspect = [];
        a.fileEdits = struct('invivoImage', [], 'invivoROI', [], 'exvivoImage', [], 'exvivoROI', []);
        a.rootFolderEdit = [];
        a.paramEdits = struct();
        a.generateMapsButton = [];
        a.autoLoadButton = [];
        a.browseRootButton = [];
        a.uploadStatus = [];
        a.uploadSummaryLabel = [];
        a.axUploadInvivo = [];
        a.axUploadExvivo = [];
        a.alignInstruction = [];
        a.addPairButton = [];
        a.clearPairsButton = [];
        a.applyTransformButton = [];
        a.anchorTable = [];
        a.alignStatus = [];
        a.alignPairCountLabel = [];
        a.axPreInvivo = [];
        a.axPreExvivo = [];
        a.axBeforeOverlay = [];
        a.axAfterOverlay = [];
        a.runSomaprintButton = [];
        a.somaStatusLabel = [];
        a.somaPreviewAxes = gobjects(1, 4);
        a.iterationTable = [];
        a.somaLogArea = [];
        a.somaNotes = [];
        a.matchTable = [];
        a.outputFolderEdit = [];
        a.browseOutputButton = [];
        a.saveWorkspaceCheck = [];
        a.exportMatButton = [];
        a.exportFullMatButton = [];
        a.exportCsvButton = [];
        a.inspectStatus = [];
        a.inspectSummaryLabel = [];
        a.prevButton = [];
        a.statusLabel = [];
        a.nextButton = [];
    end

    function buildUI()
        app.fig = uifigure('Name', 'Soma-print 2D GUI', ...
            'Position', [80 80 1520 920], 'Color', [0.98 0.98 0.99]);

        root = uigridlayout(app.fig, [3, 1]);
        root.RowHeight = {56, '1x', 44};
        root.ColumnWidth = {'1x'};
        root.Padding = [12 12 12 12];
        root.RowSpacing = 10;

        buildStepBar(root);
        buildPages(root);
        buildFooter(root);
    end

    function buildStepBar(parent)
        bar = uigridlayout(parent, [1, 4]);
        bar.Layout.Row = 1;
        bar.ColumnWidth = {'1x', '1x', '1x', '1x'};
        bar.RowSpacing = 0;
        bar.ColumnSpacing = 8;
        bar.Padding = [0 0 0 0];

        labels = {
            '1. Uploading'
            '2. Pre-alignment'
            '3. Soma-print'
            '4. Results'
            };

        for idx = 1:4
            app.stepButtons(idx) = uibutton(bar, 'push', ...
                'Text', labels{idx}, ...
                'FontSize', 14, ...
                'ButtonPushedFcn', @(~,~) requestStep(idx));
        end
    end

    function buildPages(parent)
        app.pageStack = uipanel(parent, 'BorderType', 'none');
        app.pageStack.Layout.Row = 2;

        buildUploadPage();
        buildAlignmentPage();
        buildSomaprintPage();
        buildInspectionPage();
    end

    function buildUploadPage()
        app.page1 = uipanel(app.pageStack, 'BorderType', 'none', ...
            'Units', 'normalized', 'Position', [0 0 1 1]);
        grid = uigridlayout(app.page1, [1, 2]);
        grid.RowHeight = {'1x'};
        grid.ColumnWidth = {650, '1x'};
        grid.Padding = [0 0 0 0];
        grid.RowSpacing = 10;
        grid.ColumnSpacing = 10;

        controlPanel = uipanel(grid, 'BorderType', 'none');
        controlPanel.Layout.Row = 1;
        controlPanel.Layout.Column = 1;
        controlGrid = uigridlayout(controlPanel, [4, 1]);
        controlGrid.RowHeight = {224, 56, 110, '1x'};
        controlGrid.ColumnWidth = {'1x'};
        controlGrid.Padding = [0 0 0 0];
        controlGrid.RowSpacing = 10;

        uploadTopPanel = uipanel(controlGrid, 'BorderType', 'none');
        uploadTopPanel.Layout.Row = 1;
        uploadTopPanel.Layout.Column = 1;
        uploadTopGrid = uigridlayout(uploadTopPanel, [1, 2]);
        uploadTopGrid.ColumnWidth = {170, '1x'};
        uploadTopGrid.RowHeight = {'1x'};
        uploadTopGrid.Padding = [0 0 0 0];
        uploadTopGrid.ColumnSpacing = 10;

        logoPanel = uipanel(uploadTopGrid, 'BorderType', 'none');
        logoPanel.Layout.Row = 1;
        logoPanel.Layout.Column = 1;
        logoGrid = uigridlayout(logoPanel, [1, 1]);
        logoGrid.Padding = [0 0 0 0];
        app.logoAxes = uiaxes(logoGrid);
        safeHideAxesToolbar(app.logoAxes);
        renderLogo();

        inputPanel = uipanel(uploadTopGrid, 'Title', 'Input Files');
        inputPanel.Layout.Row = 1;
        inputPanel.Layout.Column = 2;
        inputGrid = uigridlayout(inputPanel, [6, 3]);
        inputGrid.ColumnWidth = {96, '1x', 74};
        inputGrid.RowHeight = {34, 34, 34, 34, 34, 34};

        rootLabel = uilabel(inputGrid, 'Text', 'Root folder');
        rootLabel.Layout.Row = 1;
        rootLabel.Layout.Column = 1;

        app.rootFolderEdit = uieditfield(inputGrid, 'text', 'Editable', 'off', 'Value', state.rootFolder);
        app.rootFolderEdit.Layout.Row = 1;
        app.rootFolderEdit.Layout.Column = 2;

        app.browseRootButton = uibutton(inputGrid, 'push', 'Text', 'Browse', ...
            'ButtonPushedFcn', @(~,~) browseRootFolder());
        app.browseRootButton.Layout.Row = 1;
        app.browseRootButton.Layout.Column = 3;

        makeFileRow(inputGrid, 2, 'In vivo image', 'invivoImage');
        makeFileRow(inputGrid, 3, 'In vivo ROI', 'invivoROI');
        makeFileRow(inputGrid, 4, 'Ex vivo image', 'exvivoImage');
        makeFileRow(inputGrid, 5, 'Ex vivo ROI', 'exvivoROI');

        loadPanel = uipanel(controlGrid, 'BorderType', 'none');
        loadPanel.Layout.Row = 2;
        loadGrid = uigridlayout(loadPanel, [1, 7]);
        loadGrid.ColumnWidth = {'1x', 170, 12, 140, 12, '1x', 190};
        loadGrid.Padding = [0 0 0 0];
        loadGrid.ColumnSpacing = 0;

        app.autoLoadButton = uibutton(loadGrid, 'push', ...
            'Text', 'Auto load filenames', ...
            'FontWeight', 'bold', ...
            'ButtonPushedFcn', @(~,~) autoLoadFiles());
        app.autoLoadButton.Layout.Row = 1;
        app.autoLoadButton.Layout.Column = 2;

        app.generateMapsButton = uibutton(loadGrid, 'push', ...
            'Text', 'Load files', ...
            'FontWeight', 'bold', ...
            'ButtonPushedFcn', @(~,~) generateMaps());
        app.generateMapsButton.Layout.Row = 1;
        app.generateMapsButton.Layout.Column = 4;

        app.uploadSummaryLabel = uilabel(loadGrid, 'Text', 'In vivo ROIs: --   Ex vivo ROIs: --');
        app.uploadSummaryLabel.Layout.Row = 1;
        app.uploadSummaryLabel.Layout.Column = 7;
        app.uploadSummaryLabel.HorizontalAlignment = 'right';

        statusPanel = uipanel(controlGrid, 'Title', 'Loading Status');
        statusPanel.Layout.Row = 3;
        statusGrid = uigridlayout(statusPanel, [1, 1]);
        app.uploadStatus = uitextarea(statusGrid, ...
            'Editable', 'off', ...
            'Value', {'Choose the 4 files above, then click Load files.'});

        previewPanel = uipanel(grid, 'Title', 'Preview');
        previewPanel.Layout.Row = 1;
        previewPanel.Layout.Column = 2;
        previewGrid = uigridlayout(previewPanel, [1, 2]);
        previewGrid.ColumnWidth = {'1x', '1x'};
        previewGrid.RowHeight = {'1x'};
        previewGrid.Padding = [4 4 4 4];
        previewGrid.ColumnSpacing = 10;

        app.axUploadInvivo = uiaxes(previewGrid);
        title(app.axUploadInvivo, 'In vivo image + ROI');
        app.axUploadInvivo.Layout.Column = 1;

        app.axUploadExvivo = uiaxes(previewGrid);
        title(app.axUploadExvivo, 'Ex vivo image + ROI');
        app.axUploadExvivo.Layout.Column = 2;
    end

    function buildAlignmentPage()
        app.page2 = uipanel(app.pageStack, 'BorderType', 'none', ...
            'Units', 'normalized', 'Position', [0 0 1 1], 'Visible', 'off');
        grid = uigridlayout(app.page2, [1, 2]);
        grid.ColumnWidth = {300, '1x'};
        grid.Padding = [0 0 0 0];
        grid.ColumnSpacing = 10;

        controlPanel = uipanel(grid, 'Title', 'Anchor Point Selection');
        controlPanel.Layout.Column = 1;
        cg = uigridlayout(controlPanel, [8, 1]);
        cg.RowHeight = {220, 100, 40, 40, 40, '1x', 120, 24};

        app.logoAxesAlign = uiaxes(cg);
        safeHideAxesToolbar(app.logoAxesAlign);
        app.logoAxesAlign.Layout.Row = 1;
        renderLogoOnAxes(app.logoAxesAlign);

        app.alignInstruction = uitextarea(cg, ...
            'Value', { ...
            'Click "Open cpselect" to launch MATLAB''s native control-point tool.', ...
            'Select matching anchor pairs there, close/accept the picker, then return here to apply the affine transform.'}, ...
            'Editable', 'off');
        app.alignInstruction.Layout.Row = 2;

        app.addPairButton = uibutton(cg, 'push', 'Text', 'Open cpselect', ...
            'ButtonPushedFcn', @(~,~) launchCpselect());
        app.addPairButton.Layout.Row = 3;

        app.clearPairsButton = uibutton(cg, 'push', 'Text', 'Clear All', ...
            'ButtonPushedFcn', @(~,~) clearPairs());
        app.clearPairsButton.Layout.Row = 4;

        app.applyTransformButton = uibutton(cg, 'push', 'Text', 'Apply Transform', ...
            'ButtonPushedFcn', @(~,~) applyTransform());
        app.applyTransformButton.Layout.Row = 5;

        app.anchorTable = uitable(cg, ...
            'ColumnName', {'InVivo X', 'InVivo Y', 'ExVivo X', 'ExVivo Y'}, ...
            'ColumnEditable', false(1,4));
        app.anchorTable.Layout.Row = 6;

        app.alignStatus = uitextarea(cg, 'Editable', 'off');
        app.alignStatus.Layout.Row = 7;

        app.alignPairCountLabel = uilabel(cg, 'Text', 'Pairs: 0');
        app.alignPairCountLabel.Layout.Row = 8;

        visualPanel = uipanel(grid, 'Title', 'Pre-alignment Views');
        visualPanel.Layout.Column = 2;
        vg = uigridlayout(visualPanel, [2, 2]);
        vg.RowHeight = {'1x', '1x'};
        vg.ColumnWidth = {'1x', '1x'};

        app.axPreInvivo = uiaxes(vg);
        title(app.axPreInvivo, 'In vivo anchors');
        app.axPreInvivo.Layout.Row = 1;
        app.axPreInvivo.Layout.Column = 1;

        app.axPreExvivo = uiaxes(vg);
        title(app.axPreExvivo, 'Ex vivo anchors');
        app.axPreExvivo.Layout.Row = 1;
        app.axPreExvivo.Layout.Column = 2;

        app.axBeforeOverlay = uiaxes(vg);
        title(app.axBeforeOverlay, 'Before transformation, all cells');
        app.axBeforeOverlay.Layout.Row = 2;
        app.axBeforeOverlay.Layout.Column = 1;

        app.axAfterOverlay = uiaxes(vg);
        title(app.axAfterOverlay, 'After transformation, all cells');
        app.axAfterOverlay.Layout.Row = 2;
        app.axAfterOverlay.Layout.Column = 2;
    end

    function buildSomaprintPage()
        app.page3 = uipanel(app.pageStack, 'BorderType', 'none', ...
            'Units', 'normalized', 'Position', [0 0 1 1], 'Visible', 'off');
        grid = uigridlayout(app.page3, [3, 2]);
        grid.ColumnWidth = {300, '1x'};
        grid.RowHeight = {'1.1x', 270, 220};
        grid.Padding = [0 0 0 0];
        grid.RowSpacing = 10;
        grid.ColumnSpacing = 10;

        paramPanel = uipanel(grid, 'Title', 'Parameters');
        paramPanel.Layout.Row = [1 3];
        paramPanel.Layout.Column = 1;
        basicFields = {'pixellength', 'sigma', 'n_vec1', 'n_vec2'};
        optionFields = fieldnames(state.option);
        advancedFields = optionFields(~ismember(optionFields, basicFields));

        paramRoot = uigridlayout(paramPanel, [4, 1]);
        paramRoot.RowHeight = {270, 38, 132, '1x'};
        paramRoot.RowSpacing = 8;
        paramRoot.Padding = [8 8 8 8];

        app.logoAxesSoma = uiaxes(paramRoot);
        safeHideAxesToolbar(app.logoAxesSoma);
        app.logoAxesSoma.Layout.Row = 1;
        renderLogoOnAxes(app.logoAxesSoma);

        app.runSomaprintButton = uibutton(paramRoot, 'push', 'Text', 'Run Soma-print', ...
            'FontWeight', 'bold', ...
            'ButtonPushedFcn', @(~,~) runSomaprint());
        app.runSomaprintButton.Layout.Row = 2;

        basicPanel = uipanel(paramRoot, 'Title', 'Basic Parameters');
        basicPanel.Layout.Row = 3;
        basicGrid = uigridlayout(basicPanel, [numel(basicFields), 2]);
        basicGrid.ColumnWidth = {125, '1x'};
        basicGrid.RowHeight = repmat({28}, 1, numel(basicFields));
        basicGrid.RowSpacing = 4;
        basicGrid.Padding = [8 8 8 8];
        for idx = 1:numel(basicFields)
            fieldName = basicFields{idx};
            makeNumericField(basicGrid, idx, optionLabel(fieldName), fieldName, state.option.(fieldName));
        end

        advancedPanel = uipanel(paramRoot, 'Title', 'Advanced Parameters');
        advancedPanel.Layout.Row = 4;
        advancedGrid = uigridlayout(advancedPanel, [numel(advancedFields) + 1, 2]);
        advancedGrid.ColumnWidth = {125, '1x'};
        advancedGrid.RowHeight = [{44}, repmat({28}, 1, numel(advancedFields))];
        advancedGrid.RowSpacing = 4;
        advancedGrid.Padding = [8 8 8 8];
        advancedNote = uilabel(advancedGrid, ...
            'Text', 'Most users can leave these at their defaults.', ...
            'WordWrap', 'on');
        advancedNote.Layout.Row = 1;
        advancedNote.Layout.Column = [1 2];
        for idx = 1:numel(advancedFields)
            fieldName = advancedFields{idx};
            makeNumericField(advancedGrid, idx + 1, optionLabel(fieldName), fieldName, state.option.(fieldName));
        end

        logPanel = uipanel(grid, 'Title', 'Algorithm Log');
        logPanel.Layout.Row = 1;
        logPanel.Layout.Column = 2;
        lg = uigridlayout(logPanel, [1, 1]);
        app.somaLogArea = uitextarea(lg, 'Editable', 'off', ...
            'Value', state.somaLog);

        previewPanel = uipanel(grid, 'Title', 'Iteration Overlay Preview');
        previewPanel.Layout.Row = 2;
        previewPanel.Layout.Column = 2;
        pg2 = uigridlayout(previewPanel, [1, 4]);
        pg2.RowHeight = {'1x'};
        pg2.ColumnWidth = {'1x', '1x', '1x', '1x'};
        pg2.ColumnSpacing = 8;
        for idx = 1:4
            app.somaPreviewAxes(idx) = uiaxes(pg2);
            app.somaPreviewAxes(idx).Layout.Column = idx;
            showPlaceholder(app.somaPreviewAxes(idx), sprintf('Iter %d', idx));
        end

        summaryPanel = uipanel(grid, 'Title', 'Iteration Summary');
        summaryPanel.Layout.Row = 3;
        summaryPanel.Layout.Column = 2;
        sg = uigridlayout(summaryPanel, [2, 1]);
        sg.RowHeight = {32, '1x'};

        app.somaStatusLabel = uilabel(sg, 'Text', 'Run Soma-print after pre-alignment is complete.');
        app.somaStatusLabel.Layout.Row = 1;

        app.iterationTable = uitable(sg, ...
            'ColumnName', {'Iteration', 'MatchedPairs', 'MeanScore', 'MaxScore'}, ...
            'ColumnEditable', false(1,4));
        app.iterationTable.Layout.Row = 2;
    end

    function buildInspectionPage()
        app.page4 = uipanel(app.pageStack, 'BorderType', 'none', ...
            'Units', 'normalized', 'Position', [0 0 1 1], 'Visible', 'off');
        grid = uigridlayout(app.page4, [2, 3]);
        grid.RowHeight = {'2.9x', 210};
        grid.ColumnWidth = {'1x', '1.28x', '1.12x'};
        grid.Padding = [0 0 0 0];
        grid.RowSpacing = 10;
        grid.ColumnSpacing = 10;

        visualPanel = uipanel(grid, 'Title', 'Match Statistics');
        visualPanel.Layout.Row = 1;
        visualPanel.Layout.Column = [1 3];
        vg = uigridlayout(visualPanel, [2, 3]);
        vg.RowHeight = {'1x', '1x'};
        vg.ColumnWidth = {'1x', '1x', '1x'};
        vg.RowSpacing = 8;
        vg.ColumnSpacing = 8;

        for idx = 1:6
            app.inspectAxes(idx) = uiaxes(vg);
            if idx <= 3
                app.inspectAxes(idx).Layout.Row = 1;
                app.inspectAxes(idx).Layout.Column = idx;
            else
                app.inspectAxes(idx).Layout.Row = 2;
                app.inspectAxes(idx).Layout.Column = idx - 3;
            end
            showPlaceholder(app.inspectAxes(idx), sprintf('Panel %d', idx));
        end

        tablePanel = uipanel(grid, 'Title', 'Matched IDs');
        tablePanel.Layout.Row = 2;
        tablePanel.Layout.Column = 1;
        tg = uigridlayout(tablePanel, [1,1]);
        app.matchTable = uitable(tg, ...
            'ColumnName', {'id_output1', 'id_output2', 'somaprint_score', 'posterior_probability'}, ...
            'ColumnEditable', false(1,4));

        exportPanel = uipanel(grid, 'Title', 'Export');
        exportPanel.Layout.Row = 2;
        exportPanel.Layout.Column = 2;
        eg = uigridlayout(exportPanel, [6, 2]);
        eg.RowHeight = {32, 32, 32, 32, 44, 22};
        eg.ColumnWidth = {'1x', '1x'};
        eg.ColumnSpacing = 8;

        app.browseOutputButton = uibutton(eg, 'push', 'Text', 'Browse Output Folder', ...
            'ButtonPushedFcn', @(~,~) browseOutputFolder());
        app.browseOutputButton.Layout.Row = 1;
        app.browseOutputButton.Layout.Column = [1 2];

        app.outputFolderEdit = uieditfield(eg, 'text', 'Editable', 'off', ...
            'Value', state.outputFolder);
        app.outputFolderEdit.Layout.Row = 2;
        app.outputFolderEdit.Layout.Column = [1 2];

        app.exportMatButton = uibutton(eg, 'push', 'Text', 'Export results (.mat)', ...
            'ButtonPushedFcn', @(~,~) exportMatches('mat'));
        app.exportMatButton.Layout.Row = 3;
        app.exportMatButton.Layout.Column = 1;
        app.exportCsvButton = uibutton(eg, 'push', 'Text', 'Export output_summary (.csv)', ...
            'ButtonPushedFcn', @(~,~) exportMatches('csv'));
        app.exportCsvButton.Layout.Row = 3;
        app.exportCsvButton.Layout.Column = 2;

        app.exportFullMatButton = uibutton(eg, 'push', 'Text', 'Export full data (.mat)', ...
            'ButtonPushedFcn', @(~,~) exportMatches('fullmat'));
        app.exportFullMatButton.Layout.Row = 4;
        app.exportFullMatButton.Layout.Column = [1 2];

        app.inspectStatus = uitextarea(eg, 'Editable', 'off');
        app.inspectStatus.Layout.Row = 5;
        app.inspectStatus.Layout.Column = [1 2];

        app.inspectSummaryLabel = uilabel(eg, 'Text', 'No inspection results yet.');
        app.inspectSummaryLabel.FontSize = 11;
        app.inspectSummaryLabel.Layout.Row = 6;
        app.inspectSummaryLabel.Layout.Column = [1 2];

        logoPanel = uipanel(grid, 'Title', 'Logo');
        logoPanel.Layout.Row = 2;
        logoPanel.Layout.Column = 3;
        lg2 = uigridlayout(logoPanel, [1, 1]);
        lg2.Padding = [6 6 6 6];
        app.logoAxesInspect = uiaxes(lg2);
        safeHideAxesToolbar(app.logoAxesInspect);
        renderLogoOnAxes(app.logoAxesInspect);
    end

    function buildFooter(parent)
        footer = uigridlayout(parent, [1, 3]);
        footer.Layout.Row = 3;
        footer.ColumnWidth = {120, '1x', 120};
        footer.Padding = [0 0 0 0];

        app.prevButton = uibutton(footer, 'push', ...
            'Text', 'Previous', 'ButtonPushedFcn', @(~,~) goPrevious());
        app.prevButton.Layout.Column = 1;

        app.statusLabel = uilabel(footer, 'Text', 'Ready.');
        app.statusLabel.Layout.Column = 2;
        app.statusLabel.HorizontalAlignment = 'center';

        app.nextButton = uibutton(footer, 'push', ...
            'Text', 'Next', 'ButtonPushedFcn', @(~,~) goNext());
        app.nextButton.Layout.Column = 3;
    end

    function makeFileRow(parent, row, labelText, fieldName)
        lbl = uilabel(parent, 'Text', labelText);
        lbl.Layout.Row = row;
        lbl.Layout.Column = 1;

        app.fileEdits.(fieldName) = uieditfield(parent, 'text', 'Editable', 'off');
        app.fileEdits.(fieldName).FontSize = 11;
        app.fileEdits.(fieldName).Layout.Row = row;
        app.fileEdits.(fieldName).Layout.Column = 2;

        btn = uibutton(parent, 'push', 'Text', 'Browse', ...
            'ButtonPushedFcn', @(~,~) browseFile(fieldName));
        btn.FontSize = 11;
        btn.Layout.Row = row;
        btn.Layout.Column = 3;
    end

    function makeNumericField(parent, row, labelText, fieldName, defaultValue)
        lbl = uilabel(parent, 'Text', labelText);
        lbl.Layout.Row = row;
        lbl.Layout.Column = 1;

        app.paramEdits.(fieldName) = uieditfield(parent, 'numeric', ...
            'Value', defaultValue, 'LowerLimit', -Inf);
        app.paramEdits.(fieldName).Layout.Row = row;
        app.paramEdits.(fieldName).Layout.Column = 2;
    end

    function renderLogo()
        logoPath = resolveLogoPath();
        renderLogoOnAxes(app.logoAxes, logoPath);
    end

    function safeHideAxesToolbar(ax)
        try
            ax.Toolbar.Visible = 'off';
        catch
            % Older MATLAB releases may not expose Toolbar on uiaxes.
        end
    end

    function renderLogoOnAxes(ax, logoPath)
        if nargin < 2
            logoPath = resolveLogoPath();
        end
        cla(ax);
        if exist(logoPath, 'file')
            logoImage = imread(logoPath);
            image(ax, logoImage);
            axis(ax, 'image');
            ax.XTick = [];
            ax.YTick = [];
            ax.Visible = 'off';
        else
            showPlaceholder(ax, 'Soma-print');
        end
    end

    function logoPath = resolveLogoPath()
        preferredPath = fullfile(pkgRoot, 'Documents', 'Logo_v1d33.jpg');
        secondaryPath = fullfile(pkgRoot, 'Documents', 'Logo_v1d32.png');
        fallbackPath = fullfile(pkgRoot, 'Documents', 'Somaprint_logo.png');
        if exist(preferredPath, 'file')
            logoPath = preferredPath;
        elseif exist(secondaryPath, 'file')
            logoPath = secondaryPath;
        else
            logoPath = fallbackPath;
        end
    end

    function browseFile(fieldName)
        [file, path] = uigetfile({'*.*', 'All Files'}, ['Select ', fieldName]);
        if isequal(file, 0)
            return
        end
        fullPath = fullfile(path, file);
        state.files.(fieldName) = fullPath;
        app.fileEdits.(fieldName).Value = fullPath;
        clearFromStep(1);
        if ~isempty(app.uploadStatus) && isvalid(app.uploadStatus)
            state.uploadLog = { ...
                'Files selected. Click Load files to generate maps.', ...
                ['Last selected: ', fullPath]};
            app.uploadStatus.Value = state.uploadLog;
        end
        app.uploadSummaryLabel.Text = 'In vivo ROIs: --   Ex vivo ROIs: --';
        setStatus(['Selected ', fullPath]);
        refreshAll();
    end

    function browseRootFolder()
        folderPath = uigetdir(state.rootFolder, 'Select Root Folder');
        if isequal(folderPath, 0)
            return
        end
        state.rootFolder = folderPath;
        app.rootFolderEdit.Value = folderPath;
        clearFromStep(1);
        state.uploadLog = { ...
            'Root folder selected.', ...
            ['Folder: ', folderPath], ...
            'Click Auto load filenames to search this folder, or browse files manually.'};
        app.uploadStatus.Value = state.uploadLog;
        app.uploadSummaryLabel.Text = 'In vivo ROIs: --   Ex vivo ROIs: --';
        setStatus(['Selected root folder: ', folderPath]);
        refreshAll();
    end

    function browseOutputFolder()
        folderPath = uigetdir(state.outputFolder, 'Select Output Folder');
        if isequal(folderPath, 0)
            return
        end
        state.outputFolder = folderPath;
        if ~isempty(app.outputFolderEdit) && isvalid(app.outputFolderEdit)
            app.outputFolderEdit.Value = folderPath;
        end
        setStatus(['Selected output folder: ', folderPath]);
    end

    function autoLoadFiles()
        if ~isempty(app.uploadStatus) && isvalid(app.uploadStatus)
            state.uploadLog = { ...
                'Auto-loading from selected root folder...', ...
                ['Root folder: ', state.rootFolder]};
            app.uploadStatus.Value = state.uploadLog;
        end
        setStatus('Auto-loading file paths...');
        drawnow;

        try
            [invivoImage, exvivoImage, invivoROI, exvivoROI, logLines] = autoLoadFilesWithLog(state.rootFolder);
            state.files.invivoImage = fullfile(state.rootFolder, invivoImage);
            state.files.exvivoImage = fullfile(state.rootFolder, exvivoImage);
            state.files.invivoROI = fullfile(state.rootFolder, invivoROI);
            state.files.exvivoROI = fullfile(state.rootFolder, exvivoROI);

            app.fileEdits.invivoImage.Value = state.files.invivoImage;
            app.fileEdits.exvivoImage.Value = state.files.exvivoImage;
            app.fileEdits.invivoROI.Value = state.files.invivoROI;
            app.fileEdits.exvivoROI.Value = state.files.exvivoROI;

            clearFromStep(1);
            state.uploadLog = { ...
                'Auto-load complete.', ...
                ['Root folder: ', state.rootFolder], ...
                ['In vivo image: ', invivoImage], ...
                ['In vivo ROI: ', invivoROI], ...
                ['Ex vivo image: ', exvivoImage], ...
                ['Ex vivo ROI: ', exvivoROI], ...
                'Click Load files to generate maps.', ...
                '--- Auto-load log ---'};
            state.uploadLog = [state.uploadLog(:); logLines(:)];
            app.uploadStatus.Value = state.uploadLog;
            app.uploadSummaryLabel.Text = 'In vivo ROIs: --   Ex vivo ROIs: --';
            setStatus('Auto-load complete. Ready to load files.');
            refreshAll();
        catch ME
            state.uploadLog = { ...
                'Auto-load failed.', ...
                ['Root folder: ', state.rootFolder], ...
                ME.message};
            app.uploadStatus.Value = state.uploadLog;
            setStatus('Auto-load failed.');
            uialert(app.fig, ME.message, 'Auto Load Error');
        end
    end

    function [invivoImage, exvivoImage, invivoROI, exvivoROI, logLines] = autoLoadFilesWithLog(rootFolder)
        invivoImage = '';
        exvivoImage = '';
        invivoROI = '';
        exvivoROI = '';
        originalFolder = pwd;
        cleanup = onCleanup(@() cd(originalFolder)); %#ok<NASGU>
        cd(rootFolder);
        logText = evalc('[invivoImage, exvivoImage, invivoROI, exvivoROI] = AutoLoadFiles;');
        logLines = splitLogLines(logText);
    end

    function generateMaps()
        required = struct2cell(state.files);
        if any(cellfun(@isempty, required))
            uialert(app.fig, 'Please select all four input files first.', 'Missing Files');
            return
        end

        state.uploadLog = { ...
            'Loading...', ...
            'Reading images and ROI zip files.', ...
            'This may take a moment for large ROI sets.'};
        app.uploadStatus.Value = state.uploadLog;
        setStatus('Loading input files...');
        drawnow;

        try
            setappdata(0, 'SomaprintLogger', @(msg, appendNewline) appendLiveLog('upload', msg, appendNewline));
            loggerCleanup = onCleanup(@() clearLiveLogger());
            [map1, map2, image1, image2, image2Multi, logLines] = loadMapsWithLog( ...
                state.files.invivoImage, state.files.exvivoImage, ...
                state.files.invivoROI, state.files.exvivoROI);
            state.map1 = map1;
            state.map2 = map2;
            state.image1 = image1;
            state.image2 = image2;
            state.image2Multi = image2Multi;
            state.completedStep = max(state.completedStep, 1);
            clearFromStep(2);
            state.currentStep = 1;
            state.uploadLog = { ...
                'Loading complete.', ...
                sprintf('In vivo ROIs loaded: %d', size(state.map1, 3)), ...
                sprintf('Ex vivo ROIs loaded: %d', size(state.map2, 3)), ...
                sprintf('In vivo image size: %d x %d', size(state.image1, 1), size(state.image1, 2)), ...
                sprintf('Ex vivo image size: %d x %d', size(state.image2, 1), size(state.image2, 2)), ...
                '--- ROI loading log ---'};
            state.uploadLog = [state.uploadLog(:); logLines(:)];
            app.uploadStatus.Value = state.uploadLog;
            app.uploadSummaryLabel.Text = sprintf('In vivo ROIs: %d   Ex vivo ROIs: %d', size(state.map1, 3), size(state.map2, 3));
            setStatus('Input files loaded and maps generated.');
            refreshAll();
            drawnow;
            clear loggerCleanup
            clearLiveLogger();
        catch ME
            clearLiveLogger();
            state.uploadLog = { ...
                'Loading failed.', ...
                ME.message};
            app.uploadStatus.Value = state.uploadLog;
            app.uploadSummaryLabel.Text = 'In vivo ROIs: --   Ex vivo ROIs: --';
            setStatus('Load failed.');
            uialert(app.fig, ME.message, 'Load Error');
        end
    end

    function launchCpselect()
        if isempty(state.map1) || isempty(state.map2)
            uialert(app.fig, 'Complete Step 1 first.', 'Missing Maps');
            return
        end
        app.alignStatus.Value = { ...
            'Launching cpselect...', ...
            'Use the native MATLAB window to select matching control points, then close/accept it to return here.'};
        setStatus('Waiting for cpselect...');
        drawnow;

        try
            movingImage = normalizeForDisplay(state.image2);
            fixedImage = normalizeForDisplay(state.image1);
            [movingPoints, fixedPoints] = cpselect(movingImage, fixedImage, 'Wait', true);

            if isempty(movingPoints) || isempty(fixedPoints)
                app.alignStatus.Value = { ...
                    'cpselect closed without saving any anchor pairs.', ...
                    'Open cpselect again when you are ready.'};
                setStatus('No anchor pairs selected.');
                refreshAll();
                return
            end

            if size(movingPoints, 1) ~= size(fixedPoints, 1)
                error('cpselect returned mismatched point counts.');
            end

            state.anchorPairs = [fixedPoints, movingPoints];
            state.pendingPair = [];
            state.pendingPairIndex = [];
            state.pendingSide = "invivo";
            state.pickMode = false;
            clearFromStep(2);
            state.completedStep = max(state.completedStep, 1);
            app.alignStatus.Value = { ...
                sprintf('Imported %d anchor pairs from cpselect.', size(state.anchorPairs, 1)), ...
                'Review the points in the two images, then click Apply Transform.'};
            setStatus('cpselect anchor pairs imported.');
            refreshAll();
        catch ME
            app.alignStatus.Value = { ...
                'cpselect failed or was interrupted.', ...
                ME.message};
            setStatus('cpselect failed.');
            uialert(app.fig, ME.message, 'cpselect Error');
        end
    end

    function clearPairs()
        state.anchorPairs = zeros(0, 4);
        state.pendingPair = [];
        state.pendingPairIndex = [];
        state.pendingSide = "invivo";
        state.pickMode = false;
        clearFromStep(2);
        app.alignStatus.Value = {'Cleared all anchor pairs.'};
        refreshAll();
    end

    function applyTransform()
        if size(state.anchorPairs, 1) < 3
            uialert(app.fig, 'At least 3 anchor pairs are required.', 'Not Enough Pairs');
            return
        end

        movingPoints = state.anchorPairs(:, 3:4);
        fixedPoints = state.anchorPairs(:, 1:2);

        state.pickMode = false;
        app.alignStatus.Value = { ...
            sprintf('Applying affine transform using %d anchor pairs...', size(state.anchorPairs, 1)), ...
            'Please wait while the transformed image and ROI maps are generated.'};
        setStatus('Applying affine transform...');
        drawnow;

        try
            setappdata(0, 'SomaprintLogger', @(msg, appendNewline) appendLiveLog('align', msg, appendNewline));
            loggerCleanup = onCleanup(@() clearLiveLogger());
            tform = fitAffineTransform(movingPoints, fixedPoints);
            state.tform = tform;
            appendLiveLog('align', '- Affine transform calculated. Generating transformed image.', true);
            [image2Tform, map2Tform, logLines] = applyTransformWithLog(state.image2, state.map2, tform, size(state.image1(:,:,1)));
            state.image2Tform = image2Tform;
            state.map2Tform = map2Tform;
            state.completedStep = max(state.completedStep, 2);
            clearFromStep(3);
            alignSummary = { ...
                sprintf('Applied affine transform using %d anchor pairs.', size(state.anchorPairs, 1)), ...
                sprintf('Generated transformed ex vivo ROIs: %d', size(state.map2Tform, 3)), ...
                '--- Transform log ---'};
            app.alignStatus.Value = [alignSummary(:); logLines(:); {'You can continue to Soma-print or add more anchors and re-run.'}];
            setStatus('Pre-alignment complete.');
            refreshAll();
            clear loggerCleanup
            clearLiveLogger();
        catch ME
            clearLiveLogger();
            uialert(app.fig, ME.message, 'Transform Error');
        end
    end

    function runSomaprint()
        if isempty(state.map2Tform)
            uialert(app.fig, 'Complete pre-alignment first.', 'Missing Transform');
            return
        end

        option = collectSomaprintOptions();
        option.method = 1;
        state.option = option;
        state.somaLog = {'Running Soma-print...', 'Please wait while the algorithm completes.'};
        state.iterSummary = table();
        app.iterationTable.Data = cell(0,4);
        if ~isempty(app.somaLogArea) && isvalid(app.somaLogArea)
            app.somaLogArea.Value = state.somaLog;
        end
        drawnow;

        try
            setappdata(0, 'SomaprintLogger', @(msg, appendNewline) appendLiveLog('soma', msg, appendNewline));
            setappdata(0, 'SomaprintIterationLogger', @(summary) appendIterationSummary(summary));
            loggerCleanup = onCleanup(@() clearLiveLogger());
            [scoreWeighted, idMap1, idMap2, scoreRaw, iterSummary, logLines] = ...
                runSomaprintWithLog(state.map1, state.map2Tform, option);
            state.scoreWeighted = scoreWeighted;
            state.idMap1 = idMap1;
            state.idMap2 = idMap2;
            state.scoreRaw = scoreRaw;
            state.iterSummary = iterSummary;
            state.somaLog = logLines;
            state.completedStep = max(state.completedStep, 3);
            clearFromStep(4);
            app.somaStatusLabel.Text = sprintf('Soma-print completed with %d iterations.', numel(scoreWeighted));
            setStatus('Soma-print run finished.');
            refreshAll();
            clear loggerCleanup
            clearLiveLogger();
        catch ME
            clearLiveLogger();
            uialert(app.fig, ME.message, 'Soma-print Error');
        end
    end

    function option = collectSomaprintOptions()
        option = GetDefaultOption();
        optionNames = fieldnames(app.paramEdits);
        integerFields = {'nitermax', 'nitermin', 'n_vec1', 'n_vec2', 'n_vec3', 'method'};
        positiveFields = {'nitermax', 'nitermin', 'n_vec1', 'n_vec2', 'n_vec3', 'pixellength'};

        for idx = 1:numel(optionNames)
            fieldName = optionNames{idx};
            ctrl = app.paramEdits.(fieldName);
            if isempty(ctrl) || ~isvalid(ctrl)
                continue
            end
            value = ctrl.Value;
            if any(strcmp(fieldName, integerFields))
                value = round(value);
            end
            if any(strcmp(fieldName, positiveFields))
                value = max(value, eps);
            end
            option.(fieldName) = value;
            ctrl.Value = value;
        end

        option.nitermin = min(option.nitermin, option.nitermax);
        app.paramEdits.nitermin.Value = option.nitermin;
    end

    function summaryTable = buildIterationSummary(scoreWeighted, idMap1, idMap2, option)
        %#ok<INUSD> option is kept here so summary generation stays aligned with run options.
        nIter = max([numel(scoreWeighted), numel(idMap1), numel(idMap2), 0]);
        values = cell(nIter, 4);
        for idx = 1:nIter
            matchedPairs = 0;
            meanScore = 0;
            maxScore = 0;
            if idx <= numel(scoreWeighted) && ~isempty(scoreWeighted{idx})
                scoreMatrix = scoreWeighted{idx};
                maxScore = max(scoreMatrix(:));
                if idx <= numel(idMap1) && idx <= numel(idMap2) && ~isempty(idMap1{idx}) && ~isempty(idMap2{idx})
                    ids1 = idMap1{idx};
                    ids2 = idMap2{idx};
                    matchedPairs = min(numel(ids1), numel(ids2));
                    linearIdx = sub2ind(size(scoreMatrix), ids1(1:matchedPairs), ids2(1:matchedPairs));
                    meanScore = safeMean(scoreMatrix(linearIdx));
                end
            end

            values{idx, 1} = idx;
            values{idx, 2} = matchedPairs;
            values{idx, 3} = meanScore;
            values{idx, 4} = maxScore;
        end
        summaryTable = cell2table(values, ...
            'VariableNames', {'Iteration', 'MatchedPairs', 'MeanScore', 'MaxScore'});
    end

    function lines = iterationSummaryLogLines(summaryTable)
        lines = {};
        if isempty(summaryTable)
            return
        end
        lines = cell(height(summaryTable), 1);
        for idx = 1:height(summaryTable)
            lines{idx} = sprintf('- Round %d matched cells: %d', ...
                summaryTable.Iteration(idx), summaryTable.MatchedPairs(idx));
        end
    end

    function ok = ensureInspectionResults()
        ok = false;
        if isempty(state.scoreWeighted)
            return
        end

        availableIterations = find(~cellfun(@isempty, state.scoreWeighted));
        if isempty(availableIterations)
            return
        end

        finalIter = availableIterations(end);
        if state.inspect.isReady && isequal(state.inspect.finalIter, finalIter)
            ok = true;
            return
        end

        try
            finalMatrix = state.scoreWeighted{finalIter};
            [id1, id2, outputSummary, optionOutput, ~, ~, secondbest, AUC] = ...
                Somaprint_ComputeMatchStatistics(finalMatrix, state.map1, state.map2Tform, ...
                2, state.option.lr2nd, state.option.lambda, state.option.gmmfilter, 0);

            state.inspect.id1 = id1;
            state.inspect.id2 = id2;
            state.inspect.outputSummary = outputSummary;
            state.inspect.optionOutput = optionOutput;
            state.inspect.secondbest = secondbest;
            state.inspect.AUC = AUC;
            state.inspect.finalIter = finalIter;
            state.inspect.isReady = true;
            state.completedStep = max(state.completedStep, 4);

            renderInspectionPanelsGUI(finalMatrix);
            setStatus(buildInspectionSummaryText());
            ok = true;
        catch ME
            state.inspect = emptyInspectState();
            clearInspectionAxes();
            app.inspectStatus.Value = {'Inspection generation failed.', ME.message};
            setStatus('Inspection generation failed.');
            uialert(app.fig, ME.message, 'Inspection Error');
        end
    end

    function [map1, map2, image1, image2, image2Multi] = loadMapsNoFigure(invivoImagePath, exvivoImagePath, invivoROIPath, exvivoROIPath)
        image1 = imread(invivoImagePath);

        info = imfinfo(exvivoImagePath);
        nPages = numel(info);
        if nPages > 1
            image2Multi = [];
            for k = 1:nPages
                image2Multi(:,:,k) = imread(exvivoImagePath, k, 'Info', info); %#ok<AGROW>
            end
            image2 = max(image2Multi, [], 3);
        else
            image2 = imread(exvivoImagePath);
            image2Multi = image2;
        end

        h2 = size(image2, 1);
        w2 = size(image2, 2);
        map2 = readROI(exvivoROIPath, h2, w2, 100, 100, 0.5);

        h1 = size(image1, 1);
        w1 = size(image1, 2);
        map1 = readROI(invivoROIPath, h1, w1, 100, 100, 0.75);
        image1 = resample(resample(double(image1), 100, 100), 100, 100, 'Dimension', 2);
    end

    function [map1, map2, image1, image2, image2Multi, logLines] = loadMapsWithLog(invivoImagePath, exvivoImagePath, invivoROIPath, exvivoROIPath)
        map1 = [];
        map2 = [];
        image1 = [];
        image2 = [];
        image2Multi = [];
        logText = evalc('[map1, map2, image1, image2, image2Multi] = loadMapsNoFigure(invivoImagePath, exvivoImagePath, invivoROIPath, exvivoROIPath);');
        logLines = splitLogLines(logText);
    end

    function [image2Tform, map2Tform, logLines] = applyTransformWithLog(image2, map2, tform, imageSize)
        image2Tform = [];
        map2Tform = [];
        logText = evalc('[image2Tform, map2Tform] = applyTransformNoFigure(image2, map2, tform, imageSize);');
        logLines = splitLogLines(logText);
    end

    function [image2Tform, map2Tform] = applyTransformNoFigure(image2, map2, tform, imageSize)
        outputRef = imref2d(imageSize);
        image2Tform = imwarp(image2, tform, 'OutputView', outputRef);
        map2Tform = TransformMap(map2, tform, imageSize);
    end

    function [scoreWeighted, idMap1, idMap2, scoreRaw, iterSummary, logLines] = runSomaprintWithLog(map1, map2Tform, option)
        scoreWeighted = {};
        idMap1 = {};
        idMap2 = {};
        scoreRaw = {};
        iterSummary = table();
        logText = evalc(['[scoreWeighted, idMap1, idMap2, scoreRaw] = Somaprint_Iterative(map1, map2Tform, option);' newline ...
            'iterSummary = buildIterationSummary(scoreWeighted, idMap1, idMap2, option);']);
        logLines = splitLogLines(logText);
        logLines = [logLines(:); iterationSummaryLogLines(iterSummary)];
        if isempty(logLines)
            logLines = {'Soma-print completed with no additional log output.'};
        end
    end

    function exportMatches(fmt)
        if ~state.inspect.isReady
            if ~ensureInspectionResults()
                uialert(app.fig, 'Inspection results are not available yet.', 'Nothing To Export');
                return
            end
        end

        if isempty(state.outputFolder) || exist(state.outputFolder, 'dir') ~= 7
            uialert(app.fig, 'Please choose a valid output folder first.', 'Missing Output Folder');
            return
        end

        switch lower(fmt)
            case 'mat'
                filePath = fullfile(state.outputFolder, 'somaprint_results.mat');
                id_output1 = state.inspect.id1; %#ok<NASGU>
                id_output2 = state.inspect.id2; %#ok<NASGU>
                output_summary = state.inspect.outputSummary; %#ok<NASGU>
                option_output = state.inspect.optionOutput; %#ok<NASGU>
                save(filePath, 'id_output1', 'id_output2', 'output_summary', 'option_output');
            case 'fullmat'
                filePath = fullfile(state.outputFolder, 'somaprint_full_data.mat');
                id_output1 = state.inspect.id1; %#ok<NASGU>
                id_output2 = state.inspect.id2; %#ok<NASGU>
                output_summary = state.inspect.outputSummary; %#ok<NASGU>
                option_output = state.inspect.optionOutput; %#ok<NASGU>
                map1 = state.map1; %#ok<NASGU>
                map2 = state.map2; %#ok<NASGU>
                map2_tform = state.map2Tform; %#ok<NASGU>
                tform = state.tform; %#ok<NASGU>
                fp = state.anchorPairs(:, 1:2); %#ok<NASGU>
                mp = state.anchorPairs(:, 3:4); %#ok<NASGU>
                option = state.option; %#ok<NASGU>
                image1 = state.image1; %#ok<NASGU>
                image2 = state.image2; %#ok<NASGU>
                image2_tform = state.image2Tform; %#ok<NASGU>
                score_weighted = state.scoreWeighted; %#ok<NASGU>
                id_map1 = state.idMap1; %#ok<NASGU>
                id_map2 = state.idMap2; %#ok<NASGU>
                score_raw = state.scoreRaw; %#ok<NASGU>
                save(filePath, 'id_output1', 'id_output2', 'output_summary', 'option_output', ...
                    'map1', 'map2', 'map2_tform', 'tform', 'fp', 'mp', 'option', ...
                    'image1', 'image2', 'image2_tform', 'score_weighted', 'id_map1', 'id_map2', 'score_raw');
            case 'csv'
                filePath = fullfile(state.outputFolder, 'output_summary.csv');
                outputSummary = state.inspect.outputSummary;
                T = table(outputSummary(:,1), outputSummary(:,2), outputSummary(:,3), ...
                    outputSummary(:,4), outputSummary(:,5), outputSummary(:,6), ...
                    'VariableNames', {'invivo_cell_id', 'exvivo_cell_id', 'somaprint_score', ...
                    'posterior_probability', 'likelihood_ratio', 'p_value'});
                writetable(T, filePath);
        end
        setStatus(['Exported ', upper(fmt), ' to ', filePath]);
    end

    function fileChanged = clearFromStep(step)
        fileChanged = false;
        switch step
            case 1
                fileChanged = true;
                state.map1 = [];
                state.map2 = [];
                state.image1 = [];
                state.image2 = [];
                state.image2Multi = [];
                state.anchorPairs = zeros(0, 4);
                state.pendingPair = [];
                state.pendingSide = "invivo";
                state.pickMode = false;
                state.completedStep = 0;
                clearFromStep(2);
            case 2
                state.tform = [];
                state.map2Tform = [];
                state.image2Tform = [];
                state.anchorPairs = state.anchorPairs;
                clearFromStep(3);
                state.completedStep = min(state.completedStep, 1);
            case 3
                state.scoreWeighted = {};
                state.idMap1 = {};
                state.idMap2 = {};
                state.scoreRaw = {};
                state.iterSummary = table();
                clearFromStep(4);
                state.completedStep = min(state.completedStep, 2);
            case 4
                state.inspect = emptyInspectState();
                state.completedStep = min(state.completedStep, 3);
        end
    end

    function requestStep(step)
        if step == 4 && state.completedStep >= 3
            ensureInspectionResults();
        end
        if step <= state.completedStep + 1
            state.currentStep = step;
            refreshAll();
        end
    end

    function goPrevious()
        state.currentStep = max(1, state.currentStep - 1);
        refreshAll();
    end

    function goNext()
        maxStep = min(4, state.completedStep + 1);
        state.currentStep = min(maxStep, state.currentStep + 1);
        if state.currentStep == 4 && state.completedStep >= 3
            ensureInspectionResults();
        end
        refreshAll();
    end

    function refreshAll()
        refreshStepButtons();
        refreshPages();
        refreshUploadPage();
        refreshAlignmentPage();
        refreshSomaprintPage();
        refreshInspectionPage();
        refreshFooter();
    end

    function refreshStepButtons()
        if ~isfield(app, 'page1') || isempty(app.page1) || ~isvalid(app.page1)
            return
        end
        pageList = [app.page1, app.page2, app.page3, app.page4];
        for idx = 1:4
            pageList(idx).Visible = onOff(state.currentStep == idx);
            app.stepButtons(idx).Enable = onOff(idx <= state.completedStep + 1);
            if idx == state.currentStep
                app.stepButtons(idx).BackgroundColor = [0.21 0.43 0.81];
                app.stepButtons(idx).FontColor = [1 1 1];
            elseif idx <= state.completedStep
                app.stepButtons(idx).BackgroundColor = [0.80 0.88 0.98];
                app.stepButtons(idx).FontColor = [0.1 0.1 0.1];
            else
                app.stepButtons(idx).BackgroundColor = [0.92 0.92 0.94];
                app.stepButtons(idx).FontColor = [0.45 0.45 0.45];
            end
        end
    end

    function refreshPages()
        % Visibility is controlled in refreshStepButtons.
    end

    function refreshUploadPage()
        app.rootFolderEdit.Value = state.rootFolder;
        fields = fieldnames(state.files);
        for idx = 1:numel(fields)
            app.fileEdits.(fields{idx}).Value = state.files.(fields{idx});
        end

        cla(app.axUploadInvivo);
        cla(app.axUploadExvivo);
        if isempty(state.image1) || isempty(state.map1)
            showPlaceholder(app.axUploadInvivo, 'Load input files to preview in vivo data.');
        else
            plotImageWithContours(app.axUploadInvivo, state.image1, state.map1, [0 0.7 0], []);
            drawnow limitrate;
        end
        if isempty(state.image2) || isempty(state.map2)
            showPlaceholder(app.axUploadExvivo, 'Load input files to preview ex vivo data.');
        else
            plotImageWithContours(app.axUploadExvivo, state.image2, state.map2, [0.7 0 0.7], []);
            drawnow limitrate;
        end

        if isempty(state.map1) || isempty(state.map2)
            selectedCount = sum(~cellfun(@isempty, struct2cell(state.files)));
            if selectedCount == 0
                state.uploadLog = {'Choose the 4 files above, then click Load files.'};
            else
                state.uploadLog = { ...
                    sprintf('Files selected: %d / 4', selectedCount), ...
                    'Click Load files to generate maps and count ROIs.'};
            end
            app.uploadStatus.Value = state.uploadLog;
            app.uploadSummaryLabel.Text = 'In vivo ROIs: --   Ex vivo ROIs: --';
        end
    end

    function refreshAlignmentPage()
        app.anchorTable.Data = state.anchorPairs;
        app.alignPairCountLabel.Text = sprintf('Pairs: %d', size(state.anchorPairs, 1));
        app.addPairButton.Enable = onOff(~isempty(state.map1) && ~isempty(state.map2));
        app.clearPairsButton.Enable = onOff(~isempty(state.anchorPairs));
        app.applyTransformButton.Enable = onOff(size(state.anchorPairs, 1) >= 3);
        app.addPairButton.Text = 'Open cpselect';

        renderAnchorAxis(app.axPreInvivo, state.image1, state.map1, [0 0.7 0], 1);
        renderAnchorAxis(app.axPreExvivo, state.image2, state.map2, [0.7 0 0.7], 2);

        cla(app.axBeforeOverlay);
        cla(app.axAfterOverlay);
        if isempty(state.image1) || isempty(state.image2)
            showPlaceholder(app.axBeforeOverlay, 'Step 1 data is required.');
            showPlaceholder(app.axAfterOverlay, 'Apply the affine transform to preview results.');
        elseif isempty(state.image2Tform)
            renderMapOverlayAxis(app.axBeforeOverlay, state.map1, state.map2);
            showPlaceholder(app.axAfterOverlay, 'Apply transform to show after-transformation ROI overlap.');
        else
            renderMapOverlayAxis(app.axBeforeOverlay, state.map1, state.map2);
            renderMapOverlayAxis(app.axAfterOverlay, state.map1, state.map2Tform);
        end
    end

    function refreshSomaprintPage()
        app.runSomaprintButton.Enable = onOff(~isempty(state.map2Tform));
        if isempty(state.iterSummary)
            app.iterationTable.Data = cell(0,4);
        else
            app.iterationTable.Data = table2cell(state.iterSummary);
        end
        if ~isempty(app.somaLogArea) && isvalid(app.somaLogArea)
            app.somaLogArea.Value = state.somaLog;
        end
        refreshSomaprintPreview();
    end

    function appendIterationSummary(summary)
        newRow = table(summary.iteration, summary.matchedPairs, summary.meanScore, summary.maxScore, ...
            'VariableNames', {'Iteration', 'MatchedPairs', 'MeanScore', 'MaxScore'});
        if isempty(state.iterSummary)
            state.iterSummary = newRow;
        else
            existingIdx = find(state.iterSummary.Iteration == summary.iteration, 1);
            if isempty(existingIdx)
                state.iterSummary = [state.iterSummary; newRow];
            else
                state.iterSummary(existingIdx, :) = newRow;
            end
        end
        app.iterationTable.Data = table2cell(sortrows(state.iterSummary, 'Iteration'));
        if isfield(summary, 'scoreMatrix') && ~isempty(summary.scoreMatrix)
            state.scoreWeighted{summary.iteration} = summary.scoreMatrix;
        end
        if isfield(summary, 'id1') && isfield(summary, 'id2')
            state.idMap1{summary.iteration} = summary.id1;
            state.idMap2{summary.iteration} = summary.id2;
        end
        updateSomaprintPreview(summary.iteration);
        app.somaStatusLabel.Text = sprintf('Completed iteration %d.', summary.iteration);
        drawnow limitrate;
    end

    function refreshInspectionPage()
        app.outputFolderEdit.Value = state.outputFolder;
        app.exportMatButton.Enable = onOff(state.inspect.isReady);
        app.exportFullMatButton.Enable = onOff(state.inspect.isReady);
        app.exportCsvButton.Enable = onOff(state.inspect.isReady);
        if ~state.inspect.isReady
            app.matchTable.Data = cell(0,4);
            app.inspectSummaryLabel.Text = 'No inspection results yet.';
            app.inspectStatus.Value = {'Step 4 populates automatically from the final Soma-print iteration.'};
            clearInspectionAxes();
        else
            app.matchTable.Data = buildMatchTableData();
            nMatched = numel(state.inspect.id1);
            nMap1 = size(state.map1, 3);
            nMap2 = size(state.map2Tform, 3);
            if nMap1 > 0
                percentMatched = 100 * nMatched / nMap1;
                app.inspectSummaryLabel.Text = sprintf('Matched cells: %d/%d   Ex vivo: %d', nMatched, nMap1, nMap2);
            else
                app.inspectSummaryLabel.Text = sprintf('Matched cells: %d   Ex vivo: %d', nMatched, nMap2);
            end
            app.inspectStatus.Value = { ...
                sprintf('Results built from final iteration %d.', state.inspect.finalIter), ...
                'Export output_summary (.csv) or the full MATLAB results bundle (.mat).'};
            if state.currentStep == 4
                app.statusLabel.Text = buildInspectionSummaryText();
            end
        end
    end

    function txt = buildInspectionSummaryText()
        nMatched = numel(state.inspect.id1);
        nMap1 = size(state.map1, 3);
        nMap2 = size(state.map2Tform, 3);
        if nMap1 > 0
            percentMatched = 100 * nMatched / nMap1;
            txt = sprintf('Somaprint completed: Matched cells: %d/%d , Percent: %.4f, ex vivo: %d', ...
                nMatched, nMap1, percentMatched, nMap2);
        else
            txt = sprintf('Somaprint completed: Matched cells: %d, ex vivo: %d', nMatched, nMap2);
        end
    end

    function tableData = buildMatchTableData()
        nMatched = numel(state.inspect.id1);
        tableData = num2cell(nan(nMatched, 4));
        if nMatched == 0
            tableData = cell(0, 4);
            return
        end
        outputSummary = state.inspect.outputSummary;
        if isempty(outputSummary)
            for idx = 1:nMatched
                tableData(idx, 1:2) = {state.inspect.id1(idx), state.inspect.id2(idx)};
            end
            return
        end
        for idx = 1:nMatched
            rowIdx = find(outputSummary(:,1) == state.inspect.id1(idx) & outputSummary(:,2) == state.inspect.id2(idx), 1);
            if isempty(rowIdx)
                tableData(idx, :) = {state.inspect.id1(idx), state.inspect.id2(idx), NaN, NaN};
            else
                rowData = num2cell(outputSummary(rowIdx, 1:4));
                tableData(idx, :) = rowData;
            end
        end
    end

    function refreshFooter()
        app.prevButton.Enable = onOff(state.currentStep > 1);
        app.nextButton.Enable = onOff(state.currentStep < min(4, state.completedStep + 1) && state.currentStep <= state.completedStep);
    end

    function renderAnchorAxis(ax, img, map, color, whichSide)
        cla(ax);
        if isempty(img) || isempty(map)
            showPlaceholder(ax, 'Step 1 data is required.');
            return
        end
        imagesc(ax, normalizeForDisplay(img));
        colormap(ax, bone(256));
        formatImageAxis(ax);
        hold(ax, 'on');
        if ~isempty(state.anchorPairs)
            if whichSide == 1
                pts = state.anchorPairs(:, 1:2);
            else
                pts = state.anchorPairs(:, 3:4);
            end
            scatter(ax, pts(:,1), pts(:,2), 60, [1 0.2 0.2], 'filled', ...
                'MarkerEdgeColor', [1 1 0], 'LineWidth', 1.2);
            for idx = 1:size(pts, 1)
                text(ax, pts(idx,1) + 4, pts(idx,2), sprintf('#%d', idx), ...
                    'Color', 'y', 'FontWeight', 'bold', 'FontSize', 12);
            end
        end
        hold(ax, 'off');
    end

    function renderMapOverlayAxis(ax, map1, map2)
        cla(ax);
        if isempty(map1) || isempty(map2)
            showPlaceholder(ax, 'Aligned ROI maps are required.');
            return
        end
        map1Image = max(double(map1 > 0), [], 3);
        map2Image = max(double(map2 > 0), [], 3);
        if ~isequal(size(map1Image), size(map2Image))
            map2Image = imresize(map2Image, size(map1Image));
        end
        overlay = zeros([size(map1Image), 3]);
        overlay(:,:,2) = map1Image;
        overlay(:,:,1) = map2Image;
        overlay(:,:,3) = map2Image;
        image(ax, overlay);
        formatImageAxis(ax);
    end

    function plotImageWithContours(ax, img, map, color, ids)
        imagesc(ax, normalizeForDisplay(img));
        colormap(ax, bone(256));
        formatImageAxis(ax);
        hold(ax, 'on');
        drawContours(ax, map, color, ids);
        hold(ax, 'off');
    end

    function drawContours(ax, map, color, ids)
        if isempty(map)
            return
        end
        if nargin < 4 || isempty(ids)
            ids = 1:size(map, 3);
        end
        for idx = ids
            cellImage = full(map(:,:,idx));
            maxVal = max(cellImage(:));
            if maxVal <= 0
                continue
            end
            boundaries = bwboundaries(cellImage > 0.3 * maxVal, 'noholes');
            if isempty(boundaries)
                continue
            end
            lengths = cellfun(@length, boundaries);
            boundary = boundaries{find(lengths == max(lengths), 1)};
            plot(ax, boundary(:,2), boundary(:,1), 'Color', color, 'LineWidth', 0.75);
        end
    end

    function renderInspectionPanelsGUI(finalMatrix)
        clearInspectionAxes();
        outputSummary = state.inspect.outputSummary;
        if isempty(outputSummary)
            return
        end

        score = outputSummary(:,3);
        secondbest = state.inspect.secondbest(:);
        if isempty(score) || isempty(secondbest)
            return
        end
        matchedCount = numel(state.inspect.id1);
        if matchedCount > 0
            cutoff = min(score(1:min(matchedCount, numel(score))));
        else
            cutoff = NaN;
        end

        matchedRows = min(matchedCount, size(outputSummary, 1));
        matchedScore = score(1:matchedRows);
        renderInspectionPanelSafely(1, @() renderOriginalMatchedOverlay(app.inspectAxes(1), state.map1, state.map2Tform, state.inspect.id1, state.inspect.id2));
        renderInspectionPanelSafely(2, @() renderOriginalGradientMap(app.inspectAxes(2), state.map1, state.inspect.id1, matchedScore, cutoff, [0 1 0], 'In Vivo ROI Scores'));
        renderInspectionPanelSafely(3, @() renderOriginalGradientMap(app.inspectAxes(3), state.map2Tform, state.inspect.id2, matchedScore, cutoff, [1 0 1], 'Ex Vivo ROI Scores'));
        renderInspectionPanelSafely(4, @() renderOriginalHistogram(app.inspectAxes(4), finalMatrix, score, secondbest, cutoff, false));
        renderInspectionPanelSafely(5, @() renderOriginalHistogram(app.inspectAxes(5), finalMatrix, score, secondbest, cutoff, true));
        renderInspectionPanelSafely(6, @() renderOriginalScatter(app.inspectAxes(6), score, secondbest, matchedCount, cutoff));
    end

    function renderInspectionPanelSafely(axisIndex, renderFcn)
        try
            renderFcn();
        catch ME
            showPlaceholder(app.inspectAxes(axisIndex), ME.message);
        end
    end

    function renderOriginalMatchedOverlay(ax, map1, map2, id1, id2)
        cla(ax);
        if isempty(map1) || isempty(map2) || isempty(id1) || isempty(id2)
            showPlaceholder(ax, 'No matched-cell overlay available.');
            return
        end
        mymap = [0 0 0; .5 .5 .5; 0 1 0; 1 0 1; 1 1 1];
        plotThre = 0.3;
        map1Binary = double(map1 > plotThre);
        map2Binary = double(map2 > plotThre);
        imagesc(ax, max(map1Binary(:,:,id1), [], 3) * 2 + max(map2Binary(:,:,id2), [], 3) * 3);
        colormap(ax, mymap);
        set(ax, 'FontSize', 20, 'Visible', 'off');
        title(ax, 'Matched ROI Overlay', 'Visible', 'on', 'FontSize', 14, 'FontWeight', 'bold');
        axis(ax, 'image');
    end

    function renderOriginalGradientMap(ax, map, ids, score, cutoff, baseColor, titleText)
        cla(ax);
        if isempty(map) || isempty(ids) || isempty(score)
            showPlaceholder(ax, 'ROI map unavailable.');
            return
        end
        n = 20;
        plotThre = 0.3;
        mapBinary = double(map > plotThre);
        plotMap = (mapBinary > 0) * (1 / n);
        maxScore = max(score);
        if isnan(cutoff) || maxScore <= cutoff
            cutoff = min(score);
        end
        count = min(numel(ids), numel(score));
        for idx = 1:count
            if ids(idx) < 1 || ids(idx) > size(mapBinary, 3)
                continue
            end
            intensity = 2 / n + ((1 - 2 / n) * ((score(idx) - cutoff) / max(maxScore - cutoff, eps)));
            intensity = min(max(intensity, 2 / n), 1);
            plotMap(:,:,ids(idx)) = mapBinary(:,:,ids(idx)) * intensity;
        end
        customMap = zeros(n, 3);
        customMap(1, :) = [0 0 0];
        customMap(2, :) = [0.5 0.5 0.5];
        gradient = linspace(0.4, 1, n - 2)';
        if baseColor(2) > 0
            customMap(3:end, 2) = gradient;
        else
            customMap(3:end, 1) = gradient;
            customMap(3:end, 3) = gradient;
        end
        imagesc(ax, max(plotMap, [], 3));
        colormap(ax, customMap);
        caxis(ax, [0 1]);
        set(ax, 'FontSize', 20, 'Visible', 'off');
        title(ax, titleText, 'Visible', 'on', 'FontSize', 14, 'FontWeight', 'bold');
        axis(ax, 'image');
    end

    function renderOriginalHistogram(ax, alignMatrix, score, secondbest, cutoff, useLogScale)
        cla(ax);
        score = double(score(:));
        secondbest = double(secondbest(:));
        score = score(isfinite(score));
        secondbest = secondbest(isfinite(secondbest));
        if isempty(score) || isempty(secondbest)
            showPlaceholder(ax, 'Score histogram unavailable.');
            return
        end
        fontsize = 12;
        lw = 1.5;
        nScale = 1;
        plotColor1st = [1 .65 0.45];
        plotColor2nd = [0.45 0.45 1];
        plotColor1stDark = [.6 .35 0];
        plotColor2ndDark = [0 0 .6];

        a = double(0:0.5:max(score) + 5);
        [b1, a] = hist(score, a);
        [b2, a] = hist(secondbest, a);
        b1 = b1 / trapz(a, b1);
        b2 = b2 / trapz(a, b2);
        aLr = double(a(:));
        secondbestFit = fitdist(secondbest, 'normal');
        y = normpdf(aLr, secondbestFit.mu, secondbestFit.sigma);
        gmmodel = fitOriginalGmm(alignMatrix, score, secondbest);
        gmmPdf = pdf(gmmodel, aLr) * nScale;

        if useLogScale
            plotCut = 0;
        else
            yMax = ceil(max(b2) * 100 / 10) / 10;
            plotCut = 0;
            ylim(ax, [plotCut yMax * nScale]);
        end
        plotOriginalHistogramFill(ax, b2 * nScale, a, plotColor2nd, plotCut);
        hold(ax, 'on');
        plotOriginalHistogramFill(ax, b1 * nScale, a, plotColor1st, plotCut);
        plot(ax, aLr, y(:) * nScale, 'Color', plotColor2ndDark, 'LineStyle', '--', 'LineWidth', lw);
        plot(ax, aLr, gmmPdf(:), 'Color', plotColor1stDark, 'LineStyle', '--', 'LineWidth', lw);
        if ~isnan(cutoff)
            if useLogScale
                line(ax, [mean(cutoff), mean(cutoff)], [eps, 100], 'LineStyle', '--', 'Color', [0.3 .3 0.3], 'LineWidth', lw);
            else
                yl = get(ax, 'YLim');
                if max(yl) > 0.5
                    yl(2) = 0.5;
                end
                line(ax, [mean(cutoff), mean(cutoff)], yl, 'LineStyle', '--', 'Color', [0.3 .3 0.3], 'LineWidth', lw);
                ylim(ax, yl);
            end
        end
        if useLogScale
            set(ax, 'YScale', 'log');
            ylim(ax, [0.002 1] * nScale);
            title(ax, 'Score Histogram (log)', 'FontSize', 14, 'FontWeight', 'bold');
            set(ax, 'TickLength', [0.05, 1]);
        else
            title(ax, 'Score Histogram', 'FontSize', 14, 'FontWeight', 'bold');
            set(ax, 'TickLength', [0.026, 1]);
        end
        xMax = ceil(max(score) / 10) * 10;
        if xMax <= 0
            xMax = max(score) + 5;
        end
        set(ax, 'FontSize', fontsize, 'Box', 'off', 'LineWidth', lw);
        set(ax, 'XMinorTick', 'on', 'YMinorTick', 'on');
        set(ax, 'XTick', 0:10:xMax);
        xlim(ax, [0 xMax]);
        xlabel(ax, 'Score');
        ylabel(ax, 'Density');
        hold(ax, 'off');
    end

    function gmmodel = fitOriginalGmm(alignMatrix, score, secondbest)
        lambda = state.option.lambda;
        gmmfilter = state.option.gmmfilter;
        score = double(score(:));
        secondbest = double(secondbest(:));
        secondbestFit = fitdist(secondbest, 'normal');
        idScore = find(score > (secondbestFit.mu + 3 * secondbestFit.sigma));
        if numel(idScore) >= 2
            sMu = [mean(secondbest); mean(score(idScore))];
            sSigma = [var(secondbest); var(score(idScore))];
            proportion3td = sum(score > (secondbestFit.mu + 3 * secondbestFit.sigma)) / length(score);
        else
            sMu = [mean(secondbest); max(score)];
            sSigma = [var(secondbest); var(secondbest) / 2];
            proportion3td = 1 / length(score);
        end
        s = struct();
        s.mu = sMu;
        s.Sigma(1,1,:) = sSigma;
        s.ComponentProportion = [1 - proportion3td, proportion3td];
        if gmmfilter >= 0
            scoreThreshold = mean(mean(alignMatrix)) + gmmfilter * std(reshape(alignMatrix, [], 1));
            scoreWeighted = score(score > scoreThreshold);
            if numel(scoreWeighted) < 2
                scoreWeighted = score;
            end
            gmmodel = fitgmdist(scoreWeighted, 2, 'CovarianceType', 'full', ...
                'Replicates', 1, 'RegularizationValue', lambda, 'Start', s);
        else
            gmmodel = fitgmdist(score, 2, 'CovarianceType', 'full', ...
                'Replicates', 1, 'RegularizationValue', lambda, 'Start', s);
        end
    end

    function plotOriginalHistogramFill(ax, values, xValues, color, cut)
        values = double(values(:)');
        xValues = double(xValues(:)');
        nValues = min(numel(values), numel(xValues));
        values = values(1:nValues);
        xValues = xValues(1:nValues);
        values(values < cut) = cut;
        x2 = [xValues, fliplr(xValues)];
        inbetween = [ones(size(xValues)) * cut, fliplr(values)];
        inbetween(inbetween <= 0) = eps;
        fill(ax, x2, inbetween, color, 'FaceAlpha', 0.2, 'LineStyle', 'none');
        hold(ax, 'on');
        plot(ax, xValues, values, 'Color', color, 'LineWidth', 2);
    end

    function renderOriginalScatter(ax, score, secondbest, matchedCount, cutoff)
        cla(ax);
        score = double(score(:));
        secondbest = double(secondbest(:));
        validMask = isfinite(score) & isfinite(secondbest);
        score = score(validMask);
        secondbest = secondbest(validMask);
        nPoints = min(numel(score), numel(secondbest));
        score = score(1:nPoints);
        secondbest = secondbest(1:nPoints);
        matchedCount = min(max(round(double(matchedCount)), 0), nPoints);
        fontsize = 12;
        lw = 1.5;
        plotColor1st = [1 .65 0.45];
        plotColor1stDark = [.6 .35 0];
        plot(ax, score, secondbest, '.', 'Color', [.55 .55 .55], 'MarkerSize', 7);
        hold(ax, 'on');
        if matchedCount > 0
            plot(ax, score(1:matchedCount), secondbest(1:matchedCount), '.', ...
                'Color', (plotColor1stDark + plotColor1st) / 2, 'MarkerSize', 10);
        end
        maxLine = max([score(:); secondbest(:); 1]) * 1.05;
        yl = [0, max([secondbest(:); 1]) * 1.15];
        if ~isnan(cutoff)
            line(ax, [mean(cutoff), mean(cutoff)], yl, 'LineStyle', '--', 'Color', [.3 .3 .3], 'LineWidth', lw);
        end
        line(ax, [0 maxLine], [0 maxLine], 'LineStyle', '--', 'Color', [.6 .6 .6], 'LineWidth', lw);
        xlim(ax, [0 maxLine]);
        ylim(ax, yl);
        set(ax, 'FontSize', fontsize, 'Box', 'off', 'LineWidth', lw);
        xlabel(ax, 'Soma-print score');
        ylabel(ax, 'Second-best score');
        title(ax, 'Matched Scatter', 'FontSize', 14, 'FontWeight', 'bold');
        hold(ax, 'off');
    end

    function renderMatchedOverlay(ax, map1, map2, id1, id2)
        cla(ax);
        if isempty(map1) || isempty(map2) || isempty(id1) || isempty(id2)
            showPlaceholder(ax, 'No matched-cell overlay available.');
            return
        end
        map1Image = max(double(map1(:,:,id1) > 0), [], 3);
        map2Image = max(double(map2(:,:,id2) > 0), [], 3);
        if ~isequal(size(map1Image), size(map2Image))
            map2Image = imresize(map2Image, size(map1Image));
        end
        overlay = zeros([size(map1Image), 3]);
        overlay(:,:,2) = map1Image;
        overlay(:,:,1) = map2Image;
        overlay(:,:,3) = map2Image;
        image(ax, overlay);
        title(ax, 'Matched ROI Overlay');
        formatImageAxis(ax);
    end

    function renderGradientCellMap(ax, map, allIds, allScores, selectedIds, selectedScores, color, titleText)
        cla(ax);
        if isempty(map)
            showPlaceholder(ax, 'ROI map unavailable.');
            return
        end
        mapBinary = double(map > 0);
        if nargin < 3 || isempty(allIds)
            allIds = 1:size(map, 3);
        end
        greyMask = max(mapBinary(:,:,allIds), [], 3) * 0.45;
        rgb = zeros([size(greyMask), 3]);
        for c = 1:3
            rgb(:,:,c) = greyMask;
        end
        if isempty(selectedScores)
            selectedScores = ones(size(selectedIds));
        end
        if ~isempty(selectedIds)
            scoreMin = min(selectedScores);
            scoreMax = max(selectedScores);
            if scoreMax <= scoreMin
                scoreMax = scoreMin + 1;
            end
            for idx = 1:numel(selectedIds)
                scoreValue = selectedScores(min(idx, numel(selectedScores)));
                intensity = 0.45 + 0.55 * (scoreValue - scoreMin) / (scoreMax - scoreMin);
                mask = double(mapBinary(:,:,selectedIds(idx)) > 0);
                for c = 1:3
                    rgb(:,:,c) = max(rgb(:,:,c), mask * max(0.15, intensity * color(c)));
                end
            end
        end
        image(ax, rgb);
        formatImageAxis(ax);
        title(ax, titleText);
    end

    function renderScoreHistogram(ax, scores, secondbest, cutoff, useLogScale)
        cla(ax);
        if isempty(scores) || isempty(secondbest)
            showPlaceholder(ax, 'Score histogram unavailable.');
            return
        end

        maxScore = max([scores(:); secondbest(:); 1]);
        edges = 0:0.5:(ceil(maxScore / 5) * 5 + 5);
        if numel(edges) < 3
            edges = [0 0.5 1];
        end
        centers = edges(1:end-1) + diff(edges) / 2;

        scoreHist = histcounts(scores, edges, 'Normalization', 'pdf');
        secondHist = histcounts(secondbest, edges, 'Normalization', 'pdf');
        scoreSmooth = smoothdata(scoreHist, 'gaussian', max(3, round(numel(scoreHist) / 10)));
        secondSmooth = smoothdata(secondHist, 'gaussian', max(3, round(numel(secondHist) / 10)));

        if useLogScale
            plotCut = 0.002;
        else
            plotCut = 0;
        end
        plotHistogramGUI(ax, centers, secondHist, [0.35 0.35 1], plotCut);
        plotHistogramGUI(ax, centers, scoreHist, [1 0.62 0.32], plotCut);
        hold(ax, 'on');
        plot(ax, centers, max(secondSmooth, plotCut), '--', 'Color', [0 0 0.75], 'LineWidth', 1.5);
        plot(ax, centers, max(scoreSmooth, plotCut), '--', 'Color', [0.65 0.35 0], 'LineWidth', 1.5);
        if ~isnan(cutoff)
            xline(ax, cutoff, '--', 'Color', [0.35 0.35 0.35], 'LineWidth', 1.5);
        end
        if useLogScale
            set(ax, 'YScale', 'log');
            ylim(ax, [0.002 1]);
            title(ax, 'Score Histogram (log)');
        else
            ylim(ax, [0, max([scoreHist, secondHist, scoreSmooth, secondSmooth]) * 1.25 + eps]);
            title(ax, 'Score Histogram');
        end
        hold(ax, 'off');
        set(ax, 'Box', 'off', 'LineWidth', 1.5, 'FontSize', 12);
        xlabel(ax, 'Score');
        ylabel(ax, 'Density');
        xlim(ax, [0 edges(end)]);
    end

    function renderScoreScatter(ax, scores, secondbest, selectedMask, cutoff, finalMatrix)
        cla(ax);
        if isempty(scores) || isempty(secondbest)
            showPlaceholder(ax, 'Score scatter unavailable.');
            return
        end
        plot(ax, scores(~selectedMask), secondbest(~selectedMask), '.', 'Color', [0.75 0.75 0.75], 'MarkerSize', 7);
        hold(ax, 'on');
        plot(ax, scores(selectedMask), secondbest(selectedMask), '.', 'Color', [0.9 0.45 0.05], 'MarkerSize', 10);
        maxLine = max([scores(:); secondbest(:); 1]) * 1.05;
        plot(ax, [0 maxLine], [0 maxLine], '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.2);
        if ~isnan(cutoff)
            xline(ax, cutoff, '--', 'Color', [0.35 0.35 0.35], 'LineWidth', 1.5);
        end
        hold(ax, 'off');
        set(ax, 'Box', 'off', 'LineWidth', 1.5, 'FontSize', 12);
        xlim(ax, [0 maxLine]);
        ylim(ax, [0 max([secondbest(:); 1]) * 1.15]);
        xlabel(ax, 'Soma-print score');
        ylabel(ax, 'Second-best score');
        title(ax, 'Matched Scatter');
    end

    function plotHistogramGUI(ax, xValues, yValues, color, cut)
        yPlot = yValues(:)';
        yPlot(yPlot < cut) = cut;
        xPlot = xValues(:)';
        fill(ax, [xPlot, fliplr(xPlot)], [ones(size(xPlot)) * cut, fliplr(yPlot)], ...
            color, 'FaceAlpha', 0.18, 'LineStyle', 'none');
        hold(ax, 'on');
        plot(ax, xPlot, yPlot, 'Color', color, 'LineWidth', 1.5);
    end

    function refreshSomaprintPreview()
        for idx = 1:numel(app.somaPreviewAxes)
            updateSomaprintPreview(idx);
        end
    end

    function updateSomaprintPreview(iterationIndex)
        if iterationIndex > numel(app.somaPreviewAxes)
            return
        end
        ax = app.somaPreviewAxes(iterationIndex);
        if isempty(ax) || ~isvalid(ax)
            return
        end
        cla(ax);
        if iterationIndex <= numel(state.idMap1) && iterationIndex <= numel(state.idMap2) && ...
                ~isempty(state.idMap1{iterationIndex}) && ~isempty(state.idMap2{iterationIndex}) && ~isempty(state.map2Tform)
            renderMatchedOverlay(ax, state.map1, state.map2Tform, state.idMap1{iterationIndex}, state.idMap2{iterationIndex});
            title(ax, sprintf('Iteration %d', iterationIndex));
        else
            showPlaceholder(ax, sprintf('Iter %d', iterationIndex));
        end
    end

    function clearInspectionAxes()
        for idx = 1:numel(app.inspectAxes)
            showPlaceholder(app.inspectAxes(idx), sprintf('Panel %d', idx));
        end
    end

    function drawAnchorMarker(ax, x, y, color, idx, isPending)
        plot(ax, [x-8, x+8], [y, y], '-', 'Color', color, 'LineWidth', 2.0);
        plot(ax, [x, x], [y-8, y+8], '-', 'Color', color, 'LineWidth', 2.0);
        plot(ax, x, y, 'o', 'Color', color, 'MarkerSize', 12, 'LineWidth', 1.6);
        if nargin >= 6 && isPending
            text(ax, x + 6, y - 6, sprintf('Pending #%d', idx), 'Color', color, ...
                'FontWeight', 'bold', 'FontSize', 12, 'BackgroundColor', [0 0 0]);
        end
    end

    function img = normalizeForDisplay(img)
        if isempty(img)
            img = [];
            return
        end
        if ndims(img) == 3 && size(img, 3) > 1
            img = squeeze(img(:,:,1));
        end
        img = normimage(double(img), 2);
    end

    function overlay = makeOverlayImage(img1, img2)
        base = normalizeForDisplay(img1);
        moving = normalizeForDisplay(img2);
        if ~isequal(size(base), size(moving))
            moving = imresize(moving, size(base));
        end
        overlay = zeros([size(base), 3]);
        overlay(:,:,1) = moving;
        overlay(:,:,2) = base;
        overlay(:,:,3) = moving;
    end

    function formatImageAxis(ax)
        axis(ax, 'image');
        ax.XTick = [];
        ax.YTick = [];
        ax.Box = 'on';
        ax.YDir = 'reverse';
    end

    function showPlaceholder(ax, textValue)
        cla(ax);
        ax.Visible = 'on';
        text(ax, 0.5, 0.5, textValue, 'HorizontalAlignment', 'center', ...
            'Color', [0.4 0.4 0.4], 'FontSize', 13);
        ax.XLim = [0 1];
        ax.YLim = [0 1];
        ax.XTick = [];
        ax.YTick = [];
    end

    function tf = fitAffineTransform(movingPoints, fixedPoints)
        if exist('fitgeotform2d', 'file') == 2
            tf = fitgeotform2d(movingPoints, fixedPoints, 'affine');
        else
            tf = fitgeotrans(movingPoints, fixedPoints, 'affine');
        end
    end

    function value = safeMean(x)
        if isempty(x)
            value = 0;
        else
            value = mean(x(:), 'omitnan');
        end
    end

    function s = emptyInspectState()
        s = struct('id1', [], 'id2', [], 'outputSummary', [], ...
            'optionOutput', struct(), 'secondbest', [], 'AUC', NaN, ...
            'finalIter', [], 'isReady', false );
    end

    function lines = splitLogLines(logText)
        if isempty(logText)
            lines = {'No log output.'};
            return
        end
        rawLines = regexp(logText, '\r\n|\n|\r', 'split');
        rawLines = rawLines(~cellfun(@isempty, strtrim(rawLines)));
        if isempty(rawLines)
            lines = {'No log output.'};
            return
        end
        lines = rawLines(:);
    end

    function appendLiveLog(channel, message, appendNewline)
        if nargin < 3
            appendNewline = true;
        end
        lineText = char(string(message));
        switch channel
            case 'upload'
                state.uploadLog = appendLogLines(state.uploadLog, lineText, appendNewline);
                if ~isempty(app.uploadStatus) && isvalid(app.uploadStatus)
                    app.uploadStatus.Value = state.uploadLog;
                end
            case 'soma'
                state.somaLog = appendLogLines(state.somaLog, lineText, appendNewline);
                if ~isempty(app.somaLogArea) && isvalid(app.somaLogArea)
                    app.somaLogArea.Value = state.somaLog;
                end
            case 'align'
                currentAlign = {};
                if ~isempty(app.alignStatus) && isvalid(app.alignStatus)
                    currentAlign = app.alignStatus.Value;
                end
                updatedAlign = appendLogLines(currentAlign, lineText, appendNewline);
                if ~isempty(app.alignStatus) && isvalid(app.alignStatus)
                    app.alignStatus.Value = updatedAlign;
                end
        end
        drawnow limitrate;
    end

    function labelText = optionLabel(fieldName)
        switch fieldName
            case 'pixellength'
                labelText = 'pixellength';
            case 'sigma'
                labelText = 'sigma1';
            otherwise
                labelText = fieldName;
        end
    end

    function lines = appendLogLines(existingLines, newLine, appendNewline)
        if isempty(existingLines)
            lines = {char(newLine)};
            if ~appendNewline
                return
            end
            return
        end
        lines = existingLines(:);
        if appendNewline
            lines{end+1,1} = char(newLine);
        else
            lines{end} = [lines{end}, char(newLine)];
        end
    end

    function clearLiveLogger()
        if isappdata(0, 'SomaprintLogger')
            rmappdata(0, 'SomaprintLogger');
        end
        if isappdata(0, 'SomaprintIterationLogger')
            rmappdata(0, 'SomaprintIterationLogger');
        end
    end

    function setStatus(txt)
        app.statusLabel.Text = txt;
    end

    function out = onOff(tf)
        if tf
            out = 'on';
        else
            out = 'off';
        end
    end
end
