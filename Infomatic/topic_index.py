import re, os, json
import pandas as pd
import numpy as np
from pathlib import Path
from sklearn.feature_extraction.text import TfidfVectorizer

DATA_DIR = Path("topics")
TAGS_CACHE = Path("tags_cache.json")
DATA_DIR.mkdir(parents=True, exist_ok=True)

def reg_cleanup(text: str) -> str:
    s = (text or "").strip().lower()
    s = re.sub(r'[\s()]+', '-', s) #replaces spaces and parantheses with a signle -
    s = re.sub(r'[^a-z0-9\-]', '', s) #removes punctuation
    s = re.sub(r'-{2,}', '-', s) #Collapsing and stripping keeps tidy slugs like machine-learning
    return s.strip('-')

def extract_tags(df: pd.DataFrame, content_col: str = "Content", top_n: int = 5) -> list[list[str]]:
    vectorizer = TfidfVectorizer(
        stop_words="english",
        max_features=5000,
        ngram_range=(1, 2)
    )
    
    tfidf_matrix = vectorizer.fit_transform(df[content_col].fillna(""))
    # tfidf_matrix shape: (num_articles, num_unique_terms)
    
    feature_names = vectorizer.get_feature_names_out()  # the vocabulary
    
    all_tags = []
    for row in tfidf_matrix:
        scores = row.toarray().flatten()
        top_indices = np.argsort(scores)[::-1][:top_n]
        tags = [feature_names[i] for i in top_indices if scores[i] > 0]
        all_tags.append(tags)
    return all_tags


def get_tags(df: pd.DataFrame, content_col: str = "Content", top_n: int = 5):
    if TAGS_CACHE.exists():
        print("Loading tags from cache")
        with open(TAGS_CACHE, 'r') as file:
            return json.load(file)
    
    print("Computing Tags")
    tags = extract_tags(df, content_col, top_n)

    with open(TAGS_CACHE, "w") as f:
        json.dump(tags, f)
    return tags


def create_file_if_doesnt_exit(title:str, content:str):
    file_name = reg_cleanup(text=title)
    file_path = DATA_DIR / f"{file_name}.txt"
    try:    
        chars_written = file_path.write_text(content, encoding="utf-8")
        print(f"Written {chars_written} chars to {file_path}")
        return str(file_path)

    except PermissionError:
        print(f"Permission denied writing to {file_path}")
    except OSError as e:
        print(f"OS error writing {file_path}: {e}")
    except UnicodeEncodeError as e:
        print(f"Encoding error for '{title}': {e}")
    except KeyboardInterrupt:
        print("\nStopping manually. Saving progress...")
    except Exception as e:
        print(f"An unexpected error occurred during search_pages_equest_manager:\n {e}")


topic_index = []
ai_cleaned_csv = pd.read_csv("./ai_articles_cleaned.csv")
tags = get_tags(ai_cleaned_csv)

for index, row in ai_cleaned_csv.iterrows():
    title = row["Title"]
    content = row["Content"]
    topic_filename = create_file_if_doesnt_exit(title, content)
    if(topic_filename):
        jsonOb = {
            "id": reg_cleanup(title),
            "title": title,
            "preview": content[:300].replace("\n", " "),
            "content_file": topic_filename,
            "source" : "Wikipedia",
            "tags": tags[index]
        }
        topic_index.append(jsonOb)

with open("topic_index.json", "w") as file:
    json.dump(topic_index, file, indent=4)
