import System
import System.Web
import System.Text.RegularExpressions
import AlbumArtDownloader.Scripts
import util

class AmazonCoJp(AlbumArtDownloader.Scripts.IScript):
	Name as string:
		get: return "Amazon.co.jp"
	Version as string:
		get: return "0.01"
	Author as string:
		get: return "Watanabe SHUICHI"

	def EncodeUrl(url as string):
		return System.Web.HttpUtility.UrlEncode(url, Encoding.GetEncoding(932))

	Thumbnail as string:
		get: return "THUMBZZZ"
	Small as string:
		get: return "TZZZZZZZ"
	Medium as string:
		get: return "MZZZZZZZ"
	Large as string:
		get: return "LZZZZZZZ"
	CountryCode as string:
		get: return "09"

	def GetImgUri(asin as string, type as string) as string:
		return "http://images-jp.amazon.com/images/P/${asin}.${CountryCode}.${type}.jpg"

	def TryGetImageStream(url):
		request as System.Net.HttpWebRequest = System.Net.HttpWebRequest.Create(url)
		try:
			response = request.GetResponse()
			if response.ContentLength > 43:
				return response.GetResponseStream()
			
			response.Close()
			return null
		except e as System.Net.WebException:
			return null

	def Search(artist as string, album as string, results as IScriptResults):
		artist = StripCharacters("&.'\";:?!", artist)
		album = StripCharacters("&.'\";:?!", album)
		
		searchResultsHtml as string = GetPage("http://www.amazon.co.jp/gp/search?search-alias=popular&__mk_ja_JP=%83J%83%5E%83J%83i&field-artist=${EncodeUrl(artist)}&field-title=${EncodeUrl(album)}&sort=relevancerank")
		matches = Regex("id=\"result_[0-9]+\"[^>]*? name=\"(?<ASIN>.*?)\"", RegexOptions.Singleline | RegexOptions.IgnoreCase).Matches(searchResultsHtml)
		
		results.EstimatedCount = matches.Count
		
		for match as Match in matches:
			asin = match.Groups["ASIN"].Value
			thumb = GetImgUri(asin, Thumbnail)
			results.Add(thumb, "${artist} - ${album}", "", -1, -1, asin, CoverType.Front)

	def RetrieveFullSizeImage(fullSizeCallbackParameter):
		imageStream = TryGetImageStream(GetImgUri(fullSizeCallbackParameter, Large))
		if imageStream != null:
			return imageStream

		return TryGetImageStream(GetImgUri(fullSizeCallbackParameter, Medium))
