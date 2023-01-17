# pip install pandas-ods-reader
import re
from pandas_ods_reader import read_ods

fileRuItems = "lotro-items-ru.ods"  # Спасибо большое команде переводчиков за предоставленный файл
fileRuResult = "RuItems.lua"  # БД с Русскими названиями и ID
fileRuResultSearch = "RuItemsSearch.lua"  # БД с Русскими названиями и ID для поиска
fileItemsDbFromPlugin = "items.lua"  # БД из плагина

df = read_ods(fileRuItems, 1, columns=["A", "B"], headers=False)


# Находим в ods перевод
def search(index):
    if type(index) != int:
        index = int(index)

    found = df.A[df.A == index]
    if not found.empty:
        foundIndex = found.index[0]
        if foundIndex > 0:
            return df.B[foundIndex]


# Формируем lua файл
rulua = open(fileRuResult, "w", encoding='utf-8')
rulua.write("""RUVERSION = "33.0.5";
_RUITEMS =
{
""")

ruluasearch = open(fileRuResultSearch, "w", encoding='utf-8')
ruluasearch.write("""
_RUITEMS_SEARCH =
{
""")

src = open(fileItemsDbFromPlugin, "r", encoding='utf-8')
lines = src.readlines()
for line in lines:
    indexGroup = re.search("^\[(\d+)\]=", line)
    if indexGroup:
        index = indexGroup.group(1)
        if index:
            loc = search(index)
            if loc:
                clr = re.sub('\[[a-zA-Z]+\]', '', loc)

                rulua.write('[' + index + ']={[1]="' + clr + '";};\n')
                ruluasearch.write('[' + index + ']={[1]="' + clr.lower().replace('-', '').replace('\'', '').replace('.', "").replace(',', "").replace('  ',' ') + '";};\n')
                # rulua.write('[' + index + ']={[1]="' + clr + '";[2]="' + clr.lower().replace('-', '').replace('\'', '').replace('.', "").replace(',', "") + '";};\n')
                # print(clr)

ruluasearch.write("""};""")
rulua.write("""};""")