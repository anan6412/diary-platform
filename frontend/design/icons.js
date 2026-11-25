/* 图标精灵：内联注入，避免每个页面重复几十行 <svg>
   用法：<svg class="ico"><use href="#i-book"></use></svg>            */
(function () {
  var sprite = [
    '<svg xmlns="http://www.w3.org/2000/svg" style="display:none" aria-hidden="true">',
    '<defs>',
    '<g id="i-book" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M2.5 4.2A1.7 1.7 0 0 1 4.2 2.5h3.1a2.2 2.2 0 0 1 2.2 2.2v9.1a1.7 1.7 0 0 0-1.7-1.7H4.2A1.7 1.7 0 0 1 2.5 10.4Z"/><path d="M13.5 4.2a1.7 1.7 0 0 1 1.7 1.7v6.2a1.7 1.7 0 0 1-1.7 1.7h-3.1a1.7 1.7 0 0 0-1.7 1.7V4.7a2.2 2.2 0 0 1 2.2-2.2h2.6Z" transform="translate(0 0)"/></g>',
    '<g id="i-pen" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M11.4 2.6a1.9 1.9 0 0 1 2.7 2.7l-7.6 7.6-3.6 1 1-3.6Z"/><path d="M10.2 3.8 13 6.6"/></g>',
    '<g id="i-shield" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M8 2 13.2 4v4.2c0 3.1-2.1 5.5-5.2 6.4-3.1-.9-5.2-3.3-5.2-6.4V4Z"/><path d="M5.9 8.1 7.6 9.8l2.9-3"/></g>',
    '<g id="i-users" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><circle cx="6.3" cy="5.6" r="2.4"/><path d="M1.9 13.4c.4-2.2 2.2-3.5 4.4-3.5s4 1.3 4.4 3.5"/><path d="M11.1 3.5a2.2 2.2 0 0 1 0 4.2M12 13.4c-.1-1.1-.4-2-1-2.7 1.9-.2 3.3 1 3.7 2.7"/></g>',
    '<g id="i-tag" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M7.6 2.5h4.1a1.8 1.8 0 0 1 1.8 1.8v4.1a2 2 0 0 1-.6 1.4l-4.4 4.4a1.8 1.8 0 0 1-2.6 0L2.9 11a1.8 1.8 0 0 1 0-2.6l4.4-4.4a2 2 0 0 1 1.3-.5Z"/><circle cx="10.4" cy="5.7" r=".9"/></g>',
    '<g id="i-flag" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M3.2 14V2.6"/><path d="M3.2 3.2h7.9l-1.3 2.6 1.3 2.6H3.2"/></g>',
    '<g id="i-grid" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><rect x="2.4" y="2.4" width="4.6" height="4.6" rx="1.2"/><rect x="9" y="2.4" width="4.6" height="4.6" rx="1.2"/><rect x="2.4" y="9" width="4.6" height="4.6" rx="1.2"/><rect x="9" y="9" width="4.6" height="4.6" rx="1.2"/></g>',
    '<g id="i-spark" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M8 1.8 9.6 6 13.8 7.6 9.6 9.2 8 13.4 6.4 9.2 2.2 7.6 6.4 6Z"/></g>',
    '<g id="i-search" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><circle cx="7.2" cy="7.2" r="4.4"/><path d="M10.5 10.5 13.4 13.4"/></g>',
    '<g id="i-bell" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M4 6.6a4 4 0 0 1 8 0c0 2.6.6 4 1.1 4.7H2.9c.5-.7 1.1-2.1 1.1-4.7Z"/><path d="M6.6 13.2a1.6 1.6 0 0 0 2.8 0"/></g>',
    '<g id="i-chart" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M2.4 13.6V2.6"/><path d="M2.4 13.6h11.2"/><path d="M5.2 11V7.4M8.2 11V4.6M11.2 11V8.8"/></g>',
    '<g id="i-clock" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><circle cx="8" cy="8" r="5.6"/><path d="M8 5.1V8l2 1.3"/></g>',
    '<g id="i-check" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M3 8.4 6.2 11.6 13 4.8"/></g>',
    '<g id="i-x" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M4.2 4.2 11.8 11.8M11.8 4.2 4.2 11.8"/></g>',
    '<g id="i-arrow" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M3.4 8h9.2M8.9 4.4 12.5 8l-3.6 3.6"/></g>',
    '<g id="i-more" fill="currentColor" stroke="none"><circle cx="3.4" cy="8" r="1.3"/><circle cx="8" cy="8" r="1.3"/><circle cx="12.6" cy="8" r="1.3"/></g>',
    '<g id="i-sun" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><circle cx="8" cy="8" r="2.9"/><path d="M8 1.4v1.6M8 13v1.6M1.4 8h1.6M13 8h1.6M3.4 3.4l1.1 1.1M11.5 11.5l1.1 1.1M12.6 3.4l-1.1 1.1M4.5 11.5l-1.1 1.1"/></g>',
    '<g id="i-heart" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M8 13.2S2.6 9.9 2.6 6.4a2.9 2.9 0 0 1 5.4-1.6A2.9 2.9 0 0 1 13.4 6.4c0 3.5-5.4 6.8-5.4 6.8Z"/></g>',
    '<g id="i-logout" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M6.2 13.4H3.4a1.4 1.4 0 0 1-1.4-1.4V4a1.4 1.4 0 0 1 1.4-1.4h2.8"/><path d="M10.6 11.2 13.8 8l-3.2-3.2M13.4 8H6.4"/></g>',
    '</defs>',
    '</svg>'
  ].join('');

  var host = document.createElement('div');
  host.innerHTML = sprite;
  var node = host.firstChild;
  (document.body || document.documentElement).insertBefore(node, (document.body || document.documentElement).firstChild);
})();
