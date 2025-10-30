(require 'package)
;; A list of package repositories
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org"   . "https://orgmode.org/elpa/")
                         ("elpa"  . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")))

(package-initialize)                 ; Initializes the package system and prepares it to be used

(unless package-archive-contents     ; Unless a package archive already exists,
  (package-refresh-contents))        ; Refresh package contents so that Emacs knows which packages to load

;; Initialize use-package on non-linux platforms
(unless (package-installed-p 'use-package)        ; Unless "use-package" is installed, install "use-package"
  (package-install 'use-package))

(setq make-backup-files nil)
(set-frame-font "Fira Code Medium" nil t)
(setq column-number-mode t)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4) ; or any other preferred value
(defvaralias 'c-basic-offset 'tab-width)
(defvaralias 'cperl-indent-level 'tab-width)
(exec-path-from-shell-initialize)

(global-display-line-numbers-mode 1)
(global-visual-line-mode 1); Proper line wrapping
(global-hl-line-mode 1); Highlight current row
(show-paren-mode 1); Matches parentheses and such in every mode
(add-to-list 'default-frame-alist '(height . 59)); Default frame height.
(set-face-background hl-line-face "#f2f1f0"); Same color as greyness in gtk
(setq default-input-method "latin-1-prefix")

(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)

(add-hook 'after-init-hook #'global-flycheck-mode)
(add-hook 'LaTeX-mode-hook 'visual-line-mode)
(add-hook 'LaTeX-mode-hook 'flyspell-mode)
(add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)

(global-set-key (kbd "C-x e") 'erase-buffer)
(global-set-key (kbd "C-x a") 'revert-buffer)

;; -----------------------------------------------------

;; (use-package breadcrumb
;;   :ensure t
;;   :config
;;   (setq which-func-functions #'(breadcrumb-imenu-crumbs)))

(use-package vertico
  :ensure t
  :init
  (vertico-mode))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

;; A few more useful configurations...
(use-package emacs
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Emacs 28: Hide commands in M-x which do not work in the current mode.
  ;; Vertico commands are hidden in normal buffers.
  ;; (setq read-extended-command-predicate
  ;;       #'command-completion-default-include-p)

  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t)

  ;; TAB cycle if there are only few candidates
  (setq completion-cycle-threshold 3)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (setq tab-always-indent 'complete))

(use-package marginalia
  :ensure t
  :bind (:map minibuffer-local-map
              ("M-A" . marginalia-cycle))

  :init
  (marginalia-mode))

;; Optionally use the `orderless' completion style.
(use-package orderless
  :ensure t
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch)
  ;;       orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

(use-package magit
  :ensure t
  :bind
  ("M-M" . magit))

(use-package treemacs
  :ensure t)

(use-package projectile
  :ensure t)

(use-package format-all
  :ensure t
  :config
  (add-hook 'prog-mode-hook 'format-all-mode)
  (setq format-all-mode-hook 'format-all-ensure-formatter))

(use-package tex
  :ensure auctex
  :config
  (add-hook 'LaTeX-mode-hook 'turn-on-reftex)
  (setq reftex-plug-into-AUCTeX t))

(use-package elpy
  :ensure t
  :init
  (elpy-enable)
  (yas-global-mode)
  :config
  (setq python-shell-interpreter-args "-c exec('__import__(\\'readline\\')') -i --simple-prompt")
  (setq elpy-rpc-verbose t)
  ;;(setq elpy-rpc-virtualenv-path "/Users/jjaneto/mamba/envs/elpy-rpc")
  (setq pyvenv-activate "/Users/jjaneto/mamba"))


(use-package cmake-font-lock
  :ensure t)

;; Example configuration for Consult
(use-package consult
  :ensure t
  ;; Replace bindings. Lazily loaded due by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flycheck)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)
         ("M-s D" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window))

(use-package rust-mode
  :ensure t)

(use-package lsp-mode
  :ensure t
  :init
  (add-hook 'c-mode-hook 'lsp)
  (add-hook 'c++-mode-hook 'lsp)
  (add-hook 'rust-mode-hook 'lsp)

  (setq gc-cons-threshold 100000000)
  (setq read-process-output-max (* 1024 1024))
  (setq lsp-idle-delay 0.500))

(use-package outline-indent
  :ensure t
  :init
  (add-hook 'c-mode-hook #'outline-indent-minor-mode)
  (add-hook 'c++-mode-hook #'outline-indent-minor-mode)
  (add-hook 'rust-mode-hook #'outline-indent-minor-mode)
  :custom
  (outline-indent-ellipsis " ▼ "))

(use-package corfu
  :ensure t
  :custom
  ;; Works with `indent-for-tab-command'. Make sure tab doesn't indent when you
  ;; want to perform completion
  (tab-always-indent 'complete)
  (completion-cycle-threshold nil)      ; Always show candidates in menu

  (corfu-auto nil)
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.25)

  (corfu-min-width 80)
  (corfu-max-width corfu-min-width)     ; Always have the same width
  (corfu-count 14)
  (corfu-scroll-margin 4)
  (corfu-cycle nil)
  ;; Optional customizations
  :custom
  (corfu-auto t)                 ;; Enable auto completion
  (corfu-quit-at-boundary nil)
  (corfu-separator ?\s)            ; Use space
  (corfu-quit-no-match 'separator) ; Don't quit if there is `corfu-separator' inserted
  (corfu-preview-current 'insert)  ; Preview first candidate. Insert on input if only one
  (corfu-preselect-first t)        ; Preselect first candidate?

  ;; Other
  (corfu-echo-documentation nil)        ; Already use corfu-doc
  (lsp-completion-provider :none)       ; Use corfu instead for lsp completions
  :init
  (global-corfu-mode))

;; Optionally use the `orderless' completion style.
(use-package orderless
  :ensure t
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))


;; Add extensions
(use-package cape
  :ensure t
  :bind (("C-c p p" . completion-at-point) ;; capf
         ("C-c p t" . complete-tag)        ;; etags
         ("C-c p d" . cape-dabbrev)        ;; or dabbrev-completion
         ("C-c p h" . cape-history)
         ("C-c p f" . cape-file)
         ("C-c p k" . cape-keyword)
         ("C-c p s" . cape-elisp-symbol)
         ("C-c p e" . cape-elisp-block)
         ("C-c p a" . cape-abbrev)
         ("C-c p l" . cape-line)
         ("C-c p w" . cape-dict)
         ("C-c p :" . cape-emoji)
         ("C-c p \\" . cape-tex)
         ("C-c p _" . cape-tex)
         ("C-c p ^" . cape-tex)
         ("C-c p &" . cape-sgml)
         ("C-c p r" . cape-rfc1345)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("2d74de1cc32d00b20b347f2d0037b945a4158004f99877630afc034a674e3ab7"
     "11819dd7a24f40a766c0b632d11f60aaf520cf96bd6d8f35bae3399880937970"
     "551320837bd87074e3de38733e0a8553618c13f7208eda8ec9633d59a70bc284"
     "c650a74280e8ce4ae4b50835b7a3bc62aeffa202ffea82260e529f0a69027696"
     "dcb1cc804b9adca583e4e65755895ba0a66ef82d29464cf89a78b88ddac6ca53"
     "603a831e0f2e466480cdc633ba37a0b1ae3c3e9a4e90183833bc4def3421a961"
     default))
 '(format-all-default-formatters
   '(("Assembly" asmfmt) ("ATS" atsfmt) ("Bazel" buildifier)
     ("BibTeX" emacs-bibtex) ("C" clang-format) ("C#" csharpier)
     ("C++" clang-format) ("Cabal Config" cabal-fmt)
     ("Clojure" zprint) ("CMake" cmake-format) ("Crystal" crystal)
     ("CSS" prettier) ("Cuda" clang-format) ("D" dfmt)
     ("Dart" dart-format) ("Dhall" dhall) ("Dockerfile" dockfmt)
     ("Elixir" mix-format) ("Elm" elm-format)
     ("Emacs Lisp" emacs-lisp) ("Erlang" efmt) ("F#" fantomas)
     ("Fish" fish-indent) ("Fortran Free Form" fprettify)
     ("GLSL" clang-format) ("Go" gofmt) ("GraphQL" prettier)
     ("Haskell" brittany) ("HCL" hclfmt) ("HLSL" clang-format)
     ("HTML" html-tidy) ("HTML+EEX" mix-format)
     ("HTML+ERB" erb-format) ("Hy" emacs-hy) ("Java" clang-format)
     ("JavaScript" prettier) ("JSON" prettier) ("JSON5" prettier)
     ("Jsonnet" jsonnetfmt) ("JSX" prettier) ("Kotlin" ktlint)
     ("LaTeX" latexindent) ("Less" prettier)
     ("Literate Haskell" brittany) ("Lua" lua-fmt)
     ("Markdown" prettier) ("Meson" muon-fmt) ("Nix" nixpkgs-fmt)
     ("Objective-C" clang-format) ("OCaml" ocp-indent)
     ("Perl" perltidy) ("PHP" prettier)
     ("Protocol Buffer" clang-format) ("PureScript" purty)
     ("Python" black) ("R" styler) ("Reason" bsrefmt)
     ("ReScript" rescript) ("Ruby" rufo) ("Rust" rustfmt)
     ("Scala" scalafmt) ("SCSS" prettier) ("Shell" shfmt)
     ("Solidity" prettier) ("SQL" sqlformat) ("Svelte" prettier)
     ("Swift" swiftformat) ("Terraform" terraform-fmt)
     ("TOML" prettier) ("TSX" prettier) ("TypeScript" prettier)
     ("V" v-fmt) ("Verilog" istyle-verilog) ("Vue" prettier)
     ("XML" html-tidy) ("YAML" prettier) ("Zig" zig)
     ("_Angular" prettier) ("_AZSL" clang-format)
     ("_Beancount" bean-format) ("_Caddyfile" caddy-fmt)
     ("_Flow" prettier) ("_Gleam" gleam) ("_Ledger" ledger-mode)
     ("_Nginx" nginxfmt) ("_Snakemake" snakefmt)))
 '(package-selected-packages
   '(auctex breadcrumb cape cmake-font-lock consult corfu dracula-theme
            eat elpy exec-path-from-shell flycheck format-all lsp-mode
            magit marginalia orderless outline-indent rust-mode
            treemacs treemacs-all-the-icons treemacs-projectile
            vertico))
 '(python-interpreter "python")
 '(python-interpreter-args "-i")
 '(python-shell-interpreter "ipython")))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'erase-buffer 'disabled nil)
