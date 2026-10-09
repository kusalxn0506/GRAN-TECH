/**
 * GRAN & TECH - Core Client Application Engine
 * Handles dynamic navigation, live search, cart drawer, sessions, and toasts.
 */

const GT = {
    state: {
        cart: [],
        cartCount: 0,
        cartSubtotal: 0.0,
        user: null
    },

    init: async function() {
        await this.checkSession();
        await this.fetchCart();
        this.setupHeaderSearch();
        this.renderDrawer();
    },

    // --- DYNAMIC CONTEXT-AWARE API ROUTING ---
    apiUrl: function(endpoint) {
        const isGranTech = window.location.pathname.startsWith('/GRAN-TECH');
        const clean = endpoint.startsWith('/') ? endpoint : '/' + endpoint;
        return (isGranTech ? '/GRAN-TECH' : '') + clean;
    },

    // --- SESSION AUTHENTICATION ---
    checkSession: async function() {
        try {
            const res = await fetch(this.apiUrl('/api/auth'));
            const data = await res.json();
            if (data.loggedIn && data.user) {
                this.state.user = data.user;
                this.renderUserNav();
            } else {
                this.state.user = null;
                this.renderGuestNav();
            }
        } catch (e) {
            console.warn('Session check warning:', e);
        }
    },

    renderUserNav: function() {
        const container = document.getElementById('userNavSlot');
        if (!container) return;

        const initials = this.state.user.fullName ? this.state.user.fullName.charAt(0).toUpperCase() : 'U';
        const isAdmin = this.state.user.role === 'ADMIN';

        container.innerHTML = `
            <div class="user-dropdown-wrapper">
                <button class="user-pill-btn" onclick="GT.toggleUserDropdown()">
                    <span class="avatar-circle">${initials}</span>
                    <span class="user-name-text">${this.escapeHtml(this.state.user.fullName.split(' ')[0])}</span>
                    <i class="fal fa-chevron-down" style="font-size: 10px; margin-left: 5px;"></i>
                </button>
                <div class="user-dropdown-menu" id="userDropdownMenu">
                    <div class="dropdown-header">
                        <strong>${this.escapeHtml(this.state.user.fullName)}</strong>
                        <span>${this.escapeHtml(this.state.user.email)}</span>
                    </div>
                    <a href="my-account.html"><i class="fal fa-user-circle"></i> My Account & Orders</a>
                    ${isAdmin ? '<a href="admin.html" style="color: #ff3e3e;"><i class="fal fa-shield-alt"></i> Admin Dashboard</a>' : ''}
                    <hr style="margin: 6px 0; border: none; border-top: 1px solid #eee;">
                    <a href="javascript:void(0)" onclick="GT.logout()" style="color: #64748b;"><i class="fal fa-sign-out"></i> Sign Out</a>
                </div>
            </div>
        `;
    },

    renderGuestNav: function() {
        const container = document.getElementById('userNavSlot');
        if (!container) return;
        container.innerHTML = `<a href="sign-in.html" class="nav-link-auth">SIGN IN</a>`;
    },

    toggleUserDropdown: function() {
        const menu = document.getElementById('userDropdownMenu');
        if (menu) menu.classList.toggle('show');
    },

    logout: async function() {
        try {
            await fetch(this.apiUrl('/api/auth'), {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ action: 'logout' })
            });
            this.showToast('Signed out successfully', 'info');
            setTimeout(() => window.location.href = 'index.html', 400);
        } catch (e) {
            window.location.reload();
        }
    },

    // --- CART STATE MANAGEMENT ---
    fetchCart: async function() {
        try {
            const res = await fetch(this.apiUrl('/api/cart'));
            const data = await res.json();
            if (data.success) {
                this.updateCartUI(data);
            }
        } catch (e) {
            console.error('Fetch cart error:', e);
        }
    },

    addToCart: async function(productId, quantity = 1, variantSummary = '', unitPrice = 0) {
        try {
            const res = await fetch(this.apiUrl('/api/cart'), {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    action: 'add',
                    productId: productId,
                    quantity: quantity,
                    variantSummary: variantSummary,
                    unitPrice: unitPrice
                })
            });
            const data = await res.json();
            if (data.success) {
                this.updateCartUI(data);
                this.showToast('Added to bag successfully!', 'success');
                this.openDrawer();
            } else {
                this.showToast('Could not add to bag', 'error');
            }
        } catch (e) {
            this.showToast('Network error adding to bag', 'error');
        }
    },

    updateCartQty: async function(productId, quantity, variantSummary = '') {
        try {
            const res = await fetch(this.apiUrl('/api/cart'), {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    action: 'update',
                    productId: productId,
                    quantity: quantity,
                    variantSummary: variantSummary
                })
            });
            const data = await res.json();
            if (data.success) {
                this.updateCartUI(data);
            }
        } catch (e) {
            this.showToast('Failed to update quantity', 'error');
        }
    },

    removeCartItem: async function(productId, variantSummary = '') {
        try {
            const res = await fetch(this.apiUrl('/api/cart'), {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    action: 'remove',
                    productId: productId,
                    variantSummary: variantSummary
                })
            });
            const data = await res.json();
            if (data.success) {
                this.updateCartUI(data);
                this.showToast('Item removed from bag', 'info');
            }
        } catch (e) {
            this.showToast('Failed to remove item', 'error');
        }
    },

    updateCartUI: function(data) {
        this.state.cart = data.items || [];
        this.state.cartCount = data.totalCount || 0;
        this.state.cartSubtotal = data.subtotal || 0.0;

        // Update badge across all pages
        const bagBadges = document.querySelectorAll('.bag-count-badge');
        bagBadges.forEach(el => {
            el.textContent = `BAG (${this.state.cartCount})`;
        });

        const pillBadges = document.querySelectorAll('.cart-pill-count');
        pillBadges.forEach(el => {
            el.textContent = this.state.cartCount;
        });

        this.renderDrawer();

        // If on cart.html, trigger page rerender
        if (typeof renderCartPage === 'function') {
            renderCartPage(data);
        }
    },

    // --- SLIDE-OVER BAG DRAWER ---
    renderDrawer: function() {
        let drawer = document.getElementById('gtBagDrawer');
        if (!drawer) {
            this.injectDrawerMarkup();
            drawer = document.getElementById('gtBagDrawer');
        }

        const listContainer = document.getElementById('drawerCartList');
        const subtotalEl = document.getElementById('drawerSubtotalVal');

        if (subtotalEl) {
            subtotalEl.textContent = `$${this.state.cartSubtotal.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
        }

        if (!listContainer) return;

        if (this.state.cart.length === 0) {
            listContainer.innerHTML = `
                <div class="empty-drawer-state">
                    <i class="fal fa-shopping-bag" style="font-size: 48px; opacity: 0.3; margin-bottom: 20px;"></i>
                    <h4>Your bag is empty</h4>
                    <p>Explore high-performance computing and hardware gear in our archive.</p>
                    <a href="search.html" class="btn-shop-empty" onclick="GT.closeDrawer()">Explore Archive</a>
                </div>
            `;
            return;
        }

        listContainer.innerHTML = this.state.cart.map(item => {
            const p = item.product || {};
            const unitP = item.unitPrice || p.price || 0;
            const sub = (typeof item.subtotal === 'number') ? item.subtotal : (unitP * item.quantity);
            const variantText = item.variantSummary ? `<span class="drawer-item-variant">${this.escapeHtml(item.variantSummary)}</span>` : '';

            return `
                <div class="drawer-item">
                    <div class="drawer-item-img">
                        <img src="${p.mainImage || 'assets/images/1.jpg'}" alt="${this.escapeHtml(p.name)}">
                    </div>
                    <div class="drawer-item-info">
                        <h5>${this.escapeHtml(p.name)}</h5>
                        ${variantText}
                        <div class="drawer-item-price">$${unitP.toFixed(2)}</div>
                        <div class="drawer-item-actions">
                            <div class="drawer-qty-pill">
                                <button onclick="GT.updateCartQty(${p.id}, ${item.quantity - 1}, '${this.escapeHtml(item.variantSummary)}')">-</button>
                                <span>${item.quantity}</span>
                                <button onclick="GT.updateCartQty(${p.id}, ${item.quantity + 1}, '${this.escapeHtml(item.variantSummary)}')">+</button>
                            </div>
                            <button class="drawer-btn-remove" onclick="GT.removeCartItem(${p.id}, '${this.escapeHtml(item.variantSummary)}')">
                                <i class="fal fa-trash-alt"></i>
                            </button>
                        </div>
                    </div>
                </div>
            `;
        }).join('');
    },

    injectDrawerMarkup: function() {
        const wrapper = document.createElement('div');
        wrapper.id = 'gtDrawerContainer';
        wrapper.innerHTML = `
            <div class="gt-drawer-backdrop" id="gtDrawerBackdrop" onclick="GT.closeDrawer()"></div>
            <div class="gt-drawer-panel" id="gtBagDrawer">
                <div class="gt-drawer-header">
                    <div class="gt-drawer-title">
                        <i class="fal fa-shopping-bag"></i> Your Bag
                    </div>
                    <button class="gt-drawer-close" onclick="GT.closeDrawer()">&times;</button>
                </div>
                <div class="gt-free-shipping-bar">
                    <i class="fal fa-truck-fast"></i> Free Worldwide Courier Shipping Applied
                </div>
                <div class="gt-drawer-body" id="drawerCartList">
                    <!-- Dynamic Items -->
                </div>
                <div class="gt-drawer-footer">
                    <div class="drawer-subtotal-row">
                        <span>Subtotal</span>
                        <strong id="drawerSubtotalVal">$0.00</strong>
                    </div>
                    <p style="font-size: 11px; color: #888; margin-bottom: 20px;">Taxes and priority shipping calculated at checkout.</p>
                    <div class="drawer-btn-group">
                        <a href="cart.html" class="btn-drawer-review">Review Bag</a>
                        <a href="checkout.html" class="btn-drawer-checkout">Checkout</a>
                    </div>
                </div>
            </div>
        `;
        document.body.appendChild(wrapper);
    },

    openDrawer: function() {
        document.getElementById('gtBagDrawer')?.classList.add('open');
        document.getElementById('gtDrawerBackdrop')?.classList.add('open');
    },

    closeDrawer: function() {
        document.getElementById('gtBagDrawer')?.classList.remove('open');
        document.getElementById('gtDrawerBackdrop')?.classList.remove('open');
    },

    // --- LIVE HEADER SEARCH AUTOCOMPLETE ---
    setupHeaderSearch: function() {
        const input = document.getElementById('gtHeaderSearchInput');
        const dropdown = document.getElementById('gtHeaderSearchDropdown');
        if (!input || !dropdown) return;

        let debounceTimeout = null;

        input.addEventListener('input', (e) => {
            const query = e.target.value.trim();
            clearTimeout(debounceTimeout);

            if (query.length < 2) {
                dropdown.classList.remove('show');
                dropdown.innerHTML = '';
                return;
            }

            debounceTimeout = setTimeout(async () => {
                try {
                    const res = await fetch(this.apiUrl(`/api/products?query=${encodeURIComponent(query)}&pageSize=5`));
                    const data = await res.json();
                    if (data.success && data.products && data.products.length > 0) {
                        dropdown.innerHTML = data.products.map(p => `
                            <a href="product.html?id=${p.id}" class="search-drop-item">
                                <img src="${p.mainImage}" alt="${GT.escapeHtml(p.name)}">
                                <div class="drop-item-text">
                                    <div class="drop-item-title">${GT.escapeHtml(p.name)}</div>
                                    <div class="drop-item-sub">${GT.escapeHtml(p.categoryName || '')} &bull; $${p.price.toFixed(2)}</div>
                                </div>
                                <span class="drop-item-arrow">&rarr;</span>
                            </a>
                        `).join('') + `
                            <a href="search.html?query=${encodeURIComponent(query)}" class="search-drop-all">
                                View all results for "${GT.escapeHtml(query)}" &rarr;
                            </a>
                        `;
                        dropdown.classList.add('show');
                    } else {
                        dropdown.innerHTML = `<div class="search-drop-empty">No matching hardware found for "${GT.escapeHtml(query)}"</div>`;
                        dropdown.classList.add('show');
                    }
                } catch (err) {
                    console.error('Search fetch error:', err);
                }
            }, 250);
        });

        // Close on outside click
        document.addEventListener('click', (e) => {
            if (!input.contains(e.target) && !dropdown.contains(e.target)) {
                dropdown.classList.remove('show');
            }
            const userMenu = document.getElementById('userDropdownMenu');
            const userBtn = document.querySelector('.user-pill-btn');
            if (userMenu && userBtn && !userBtn.contains(e.target) && !userMenu.contains(e.target)) {
                userMenu.classList.remove('show');
            }
        });
    },

    // --- MODERN TOAST NOTIFICATIONS ---
    showToast: function(message, type = 'info') {
        let container = document.getElementById('gtToastContainer');
        if (!container) {
            container = document.createElement('div');
            container.id = 'gtToastContainer';
            container.className = 'gt-toast-container';
            document.body.appendChild(container);
        }

        const toast = document.createElement('div');
        toast.className = `gt-toast gt-toast-${type}`;

        let icon = '<i class="fal fa-info-circle"></i>';
        if (type === 'success') icon = '<i class="fal fa-check-circle" style="color: #10b981;"></i>';
        if (type === 'error') icon = '<i class="fal fa-times-circle" style="color: #ef4444;"></i>';
        if (type === 'warning') icon = '<i class="fal fa-exclamation-triangle" style="color: #f59e0b;"></i>';

        toast.innerHTML = `
            <div class="gt-toast-icon">${icon}</div>
            <div class="gt-toast-msg">${this.escapeHtml(message)}</div>
            <button class="gt-toast-close" onclick="this.parentElement.remove()">&times;</button>
        `;

        container.appendChild(toast);

        setTimeout(() => {
            toast.style.opacity = '0';
            toast.style.transform = 'translateY(15px)';
            toast.style.transition = 'all 0.3s ease';
            setTimeout(() => toast.remove(), 300);
        }, 3200);
    },

    formatCurrency: function(amount) {
        const val = parseFloat(amount) || 0.0;
        return '$' + val.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    },

    escapeHtml: function(str) {
        if (!str) return '';
        return String(str).replace(/[&<>"']/g, m => ({
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;',
            '"': '&quot;',
            "'": '&#39;'
        }[m]));
    }
};

// Auto-run on DOM ready
document.addEventListener('DOMContentLoaded', () => {
    GT.init();
});
