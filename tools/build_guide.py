"""Developer-only: render docs/GUIDE-zh.md as the illustrated Chinese review PDF.

Requires reportlab. Use --font-dir for a folder containing msyh.ttc,
msyhbd.ttc and consola.ttf. The PDF and source are excluded from the R tarball.
"""
from pathlib import Path
import argparse
import hashlib
import html
import json
import math
import re

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    BaseDocTemplate, Frame, PageTemplate, Paragraph, Spacer, PageBreak,
    Flowable, Table, TableStyle, Image,
)

ROOT = Path(__file__).resolve().parents[1]
WIDTH, HEIGHT = A4
MARGIN = 45
PANEL = WIDTH - 2 * MARGIN
NAVY = colors.HexColor('#173B50')
TEAL = colors.HexColor('#137F8E')
INK = colors.HexColor('#293E4C')
PALE = colors.HexColor('#EEF5F7')


def inline(text):
    text = html.escape(text, quote=False)
    text = re.sub(r'`([^`]+)`', r'<font color="#137F8E">\1</font>', text)
    text = re.sub(r'\*\*(.+?)\*\*', r'<b>\1</b>', text)
    text = re.sub(r'https?://[^\s]+',
                  lambda m: '<link href="' + m.group().replace('&amp;', '&') +
                  '" color="#137F8E">' + m.group() + '</link>', text)
    return text


class Code(Flowable):
    def __init__(self, text, language):
        Flowable.__init__(self)
        self.text, self.language = text, language
        self.size, self.leading = 9.1, 12.6

    def wrap(self, width, height):
        self.width = width
        self.rows = []
        for line in self.text.splitlines():
            row, used = '', 0
            for ch in line.expandtabs(2):
                font = 'Code' if ord(ch) < 127 else 'CN'
                advance = pdfmetrics.stringWidth(ch, font, self.size)
                if used + advance > width - 24:
                    self.rows.append(row)
                    row, used = '  ', pdfmetrics.stringWidth('  ', 'Code', self.size)
                row += ch
                used += advance
            self.rows.append(row)
        self.height = 32 + len(self.rows) * self.leading
        return self.width, self.height

    def draw(self):
        c = self.canv
        c.setFillColor(PALE)
        c.roundRect(0, 0, self.width, self.height, 5, fill=1, stroke=0)
        c.setFillColor(TEAL)
        c.setFont('CNB', 8)
        c.drawString(12, self.height - 14, 'PowerShell 终端' if self.language == 'powershell' else 'R 控制台')
        y = self.height - 31
        c.setFillColor(INK)
        for row in self.rows:
            x = 12
            for ch in row:
                font = 'Code' if ord(ch) < 127 else 'CN'
                c.setFont(font, self.size)
                c.drawString(x, y, ch)
                x += pdfmetrics.stringWidth(ch, font, self.size)
            y -= self.leading


class Architecture(Flowable):
    def wrap(self, width, height):
        self.width, self.height = width, 74
        return width, self.height

    def draw(self):
        c = self.canv
        labels = [('输入表', '原始数值和分类'), ('统计', '均值、数量、比例'),
                  ('标准图层', '点、线、面、文字'), ('输出', '图片或交互页面')]
        gap = 14
        box = (self.width - gap * 3) / 4
        for i, (title, sub) in enumerate(labels):
            x = i * (box + gap)
            c.setFillColor(PALE)
            c.setStrokeColor(TEAL)
            c.roundRect(x, 13, box, 50, 5, fill=1, stroke=1)
            c.setFillColor(NAVY)
            c.setFont('CNB', 11)
            c.drawCentredString(x + box / 2, 43, title)
            c.setFont('CN', 7.7)
            c.drawCentredString(x + box / 2, 25, sub)
            if i < 3:
                c.setStrokeColor(TEAL)
                c.line(x + box, 38, x + box + gap - 2, 38)
                c.line(x + box + gap - 2, 38, x + box + gap - 6, 41)
                c.line(x + box + gap - 2, 38, x + box + gap - 6, 35)


class GuideDoc(BaseDocTemplate):
    def __init__(self, output, **kwargs):
        super().__init__(str(output), pagesize=A4, leftMargin=MARGIN,
                         rightMargin=MARGIN, topMargin=53, bottomMargin=45,
                         title='radarsunburst：看懂、试用和检查一本通',
                         author='Muyao Shen; prepared with OpenAI Codex', **kwargs)
        self.headings = []
        self.addPageTemplates(PageTemplate(id='book',
            frames=[Frame(MARGIN, 45, PANEL, HEIGHT - 98, leftPadding=0,
                          rightPadding=0, topPadding=0, bottomPadding=0)],
            onPage=self.page_frame))

    def page_frame(self, canvas, doc):
        canvas.saveState()
        canvas.setStrokeColor(colors.HexColor('#CCDEE5'))
        canvas.line(MARGIN, HEIGHT-34, WIDTH-MARGIN, HEIGHT-34)
        canvas.setFont('CN', 8)
        canvas.setFillColor(colors.HexColor('#627B89'))
        canvas.drawString(MARGIN, HEIGHT-25, 'radarsunburst 0.1.0 | geom 接口与手动验收 | 未提交 CRAN')
        canvas.drawString(MARGIN, 25, '2026-10-20 阅读审查版 | 维护者人工确认留待你完成')
        canvas.drawRightString(WIDTH-MARGIN, 25, str(doc.page))
        canvas.restoreState()

    def afterFlowable(self, flowable):
        if getattr(flowable, 'guide_heading', None):
            title = flowable.guide_heading
            key = f'section-{len(self.headings)}'
            self.canv.bookmarkPage(key)
            self.canv.addOutlineEntry(title, key, level=0)
            self.headings.append({'title': title, 'page': self.page})


def build(font_dir, output):
    for name, filename in [('CN', 'msyh.ttc'), ('CNB', 'msyhbd.ttc'), ('Code', 'consola.ttf')]:
        pdfmetrics.registerFont(TTFont(name, str(font_dir / filename)))
    pdfmetrics.registerFontFamily('CN', normal='CN', bold='CNB', italic='CN', boldItalic='CNB')
    body = ParagraphStyle('body', fontName='CN', fontSize=11, leading=18,
                          wordWrap='CJK', textColor=INK, spaceAfter=10)
    h1 = ParagraphStyle('h1', parent=body, fontName='CNB', fontSize=20, leading=29,
                        textColor=NAVY, spaceAfter=16, keepWithNext=True)
    h2 = ParagraphStyle('h2', parent=body, fontName='CNB', fontSize=12.5, leading=20,
                        textColor=TEAL, spaceAfter=8, spaceBefore=6, keepWithNext=True)
    cell = ParagraphStyle('cell', parent=body, fontSize=9.1, leading=14, spaceAfter=0)
    head = ParagraphStyle('head', parent=cell, fontName='CNB', textColor=colors.white)
    story = []
    content = (ROOT / 'docs/GUIDE-zh.md').read_text(encoding='utf-8')
    sections = content.split('<!-- page -->')
    for part_number, part in enumerate(sections):
        if part_number:
            story.append(PageBreak())
        lines = part.strip().splitlines()
        i = 0
        while i < len(lines):
            line = lines[i]
            if not line.strip():
                i += 1
                continue
            if line.startswith('```'):
                language = line[3:].strip()
                code = []
                i += 1
                while i < len(lines) and not lines[i].startswith('```'):
                    code.append(lines[i])
                    i += 1
                story.extend([Code('\n'.join(code), language), Spacer(1, 10)])
                i += 1
                continue
            if line.startswith('|'):
                rows = []
                while i < len(lines) and lines[i].startswith('|'):
                    row = [x.strip() for x in lines[i].strip().strip('|').split('|')]
                    if not all(re.fullmatch(r'[-: ]+', x) for x in row):
                        rows.append(row)
                    i += 1
                n = len(rows[0])
                widths = {2:[.32,.68], 3:[.24,.43,.33], 4:[.24,.25,.27,.24],
                          6:[.10,.10,.16,.20,.22,.22]}.get(n,[1/n]*n)
                table = Table([[Paragraph(inline(x), head if r == 0 else cell)
                                for x in row] for r, row in enumerate(rows)],
                              colWidths=[PANEL*w for w in widths], repeatRows=1)
                table.setStyle(TableStyle([
                    ('BACKGROUND',(0,0),(-1,0),NAVY), ('VALIGN',(0,0),(-1,-1),'TOP'),
                    ('ROWBACKGROUNDS',(0,1),(-1,-1),[colors.white,PALE]),
                    ('LEFTPADDING',(0,0),(-1,-1),7),('RIGHTPADDING',(0,0),(-1,-1),7),
                    ('TOPPADDING',(0,0),(-1,-1),7),('BOTTOMPADDING',(0,0),(-1,-1),7),
                    ('LINEBELOW',(0,1),(-1,-1),.3,colors.HexColor('#D9E4E9')),
                ]))
                story.extend([table, Spacer(1, 11)])
                continue
            if line.startswith('# '):
                p = Paragraph(inline(line[2:]), h1)
                p.guide_heading = line[2:]
                story.append(p)
            elif line.startswith('## '):
                story.append(Paragraph(inline(line[3:]), h2))
            else:
                paragraphs = [line]
                i += 1
                while i < len(lines) and lines[i].strip() and not lines[i].startswith(('#','|','```','- ')):
                    paragraphs.append(lines[i])
                    i += 1
                story.append(Paragraph(inline(' '.join(paragraphs)), body))
                continue
            i += 1
        if part_number == 0:
            image = ROOT / 'artifacts/preview/component.png'
            if image.exists():
                story.append(Image(str(image), width=PANEL, height=PANEL*2/3))
                story.append(Paragraph('当前 geom_radsun() 生成的演示图。先读输入映射，再按步骤亲手验收。',cell))
        if part_number == 12:
            story.append(Architecture())
    output.parent.mkdir(parents=True, exist_ok=True)
    doc = GuideDoc(output)
    doc.build(story)
    record = dict(pages=doc.page, sections=doc.headings,
                  source_sha256=hashlib.sha256(content.encode()).hexdigest(),
                  pdf_sha256=hashlib.sha256(output.read_bytes()).hexdigest())
    (ROOT/'output/pdf/guide-page-map.json').write_text(json.dumps(record,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:v for k,v in record.items() if k!='sections'}))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--font-dir', type=Path, default=Path('C:/Windows/Fonts'))
    parser.add_argument('--output', type=Path, default=ROOT/'output/pdf/radarsunburst-code-review-and-r-package-guide-zh.pdf')
    args = parser.parse_args()
    build(args.font_dir, args.output)
